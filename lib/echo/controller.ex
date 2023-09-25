defmodule Echo.Controller do
  use GenServer, restart: :temporary
  require Logger

  alias Echo.Socket

  @supervisor __MODULE__.DynamicSupervisor
  def supervisor,
    do: {DynamicSupervisor, strategy: :one_for_one, name: @supervisor}

  def start(socket),
    do: DynamicSupervisor.start_child(@supervisor, {__MODULE__, socket})

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, {:ok, opts})

  def init({:ok, socket}) do
    {:ok, socket, {:continue, :on_connect}}
  end

  def handle_continue(:on_connect, %{handler: handler} = socket) do
    handler.on_connect(socket)
    |> handle_response()
  end

  def handle_info({:tcp, port, raw_message}, %{handler: handler} = socket) do
    handler.deserialize(raw_message)
    |> case do
      {:error, reason} ->
        Logger.error(
          "#{inspect(port)} Error | Deserialize | #{inspect(raw_message)} | #{inspect(reason)}"
        )

        handle_response({:noreply, socket})

      message ->
        message
        |> handler.handle_message(socket)
        |> handle_response()
    end
  end

  def handle_info({:tcp_closed, _port}, socket) do
    handle_exit(socket)
  end

  def handle_info(message, %{handler: handler} = socket) do
    handler.handle_info(message, socket)
    |> handle_response()
  end

  @spec handle_response(response :: Echo.Handler.no_reply()) :: {:noreply, Socket.t()}
  def handle_response({:noreply, socket}) do
    {:noreply, socket}
  end

  @spec handle_response(response :: Echo.Handler.reply()) :: {:noreply, Socket.t()}
  def handle_response({:reply, message, %{handler: handler, port: port} = socket}) do
    message = handler.serialize(message)
    :gen_tcp.send(port, message)

    {:noreply, socket}
  end

  @spec handle_response(response :: Echo.Handler.finish()) :: {:stop, :shutdown, Socket.t()}
  def handle_response({:exit, response, %{port: port} = socket}) do
    :gen_tcp.send(port, response)
    handle_exit(socket)
  end

  def handle_response({:exit, socket}) do
    handle_exit(socket)
  end

  def handle_exit(%{handler: handler} = socket) do
    handler.on_exit(socket)
    |> handle_response()

    {:stop, :shutdown, socket}
  end
end
