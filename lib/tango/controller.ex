defmodule Tango.Controller do
  @moduledoc false
  use GenServer, restart: :temporary
  alias Tango.Socket
  require Logger

  defdelegate start(socket),
    to: Tango.Controller.DynamicSupervisor

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    {:ok, socket, {:continue, :on_connect}}
  end

  def handle_continue(:on_connect, %{handler: handler} = socket) do
    socket
    |> handler.on_connect()
    |> handle_response()
  end

  def handle_info({:tcp, port, raw_message}, %{handler: handler} = socket) do
    raw_message
    |> handler.handle_in()
    |> case do
      {:error, error} ->
        Logger.error("#{inspect(port)} Decode/#{inspect(error)} :: #{inspect(raw_message)}")
        handler.handle_parse_error(error, socket)
        |> handle_response()

      message ->
        message
        |> handler.handle_message(socket)
        |> handle_response()
    end
  end

  def handle_info({:tcp_closed, port}, socket) do
    Logger.debug("-> Closed: #{inspect(port)}")
    handle_exit(socket)
  end

  def handle_info(message, %{handler: handler} = socket) do
    message
    |> handler.handle_info(socket)
    |> handle_response()
  end

  @spec handle_response(response :: Tango.Handler.no_reply()) :: {:noreply, Socket.t()}
  def handle_response({:noreply, socket}) do
    {:noreply, socket}
  end

  @spec handle_response(response :: Tango.Handler.reply()) :: {:noreply, Socket.t()}
  def handle_response({:reply, message, %{handler: handler, port: port} = socket}) do
    message = handler.handle_out(message)

    # This could fail, but if it does it's probably
    # because the port closed and there's a handle_info for that
    :gen_tcp.send(port, message)

    {:noreply, socket}
  end

  @spec handle_response(response :: Tango.Handler.finish()) :: {:stop, :shutdown, Socket.t()}
  def handle_response({:exit, response, %{port: port} = socket}) do
    :gen_tcp.send(port, response)
    handle_exit(socket)
  end

  def handle_response({:exit, socket}) do
    handle_exit(socket)
  end

  def handle_exit(%{handler: handler} = socket) do
    socket
    |> handler.on_exit()
    |> handle_response()

    {:stop, :shutdown, socket}
  end
end
