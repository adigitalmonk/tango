defmodule Echo.Controller do
  use GenServer, restart: :transient
  require Logger

  @supervisor __MODULE__.DynamicSupervisor
  def supervisor, do: {DynamicSupervisor, strategy: :one_for_one, name: @supervisor}

  def start(socket, handler),
    do: DynamicSupervisor.start_child(@supervisor, {__MODULE__, {socket, handler}})

  def start_link(opts), do: GenServer.start_link(__MODULE__, {:ok, opts})

  def init({:ok, opts}) do
    {:ok, opts, {:continue, :on_connect}}
  end

  def handle_continue(:on_connect, {socket, handler} = opts) do
    handler.on_connect(socket)
    {:noreply, opts}
  end

  def handle_info({:tcp, _port, raw_message}, {socket, handler} = opts) do
    raw_message
    |> handler.handle(socket)
    |> case do
      :ok ->
        {:noreply, opts}

      :close ->
        handler.on_exit(socket)
        {:stop, :shutdown, opts}
    end
  end
end
