defmodule Echo.Acceptor do
  alias Echo.{Socket, Controller}
  require Logger

  @supervisor __MODULE__.TaskSupervisor
  def supervisor, do: {Task.Supervisor, name: @supervisor}

  def start(tcp_listener, handler) do
    {:ok, _pid} =
      Task.Supervisor.start_child(
        @supervisor,
        fn -> listen(tcp_listener, handler) end,
        restart: :temporary
      )
  end

  def listen(tcp_listener, handler) do
    tcp_listener
    |> :gen_tcp.accept()
    |> case do
      {:ok, port} -> hand_off(port, handler)
      {:error, reason} -> Logger.error("Couldn't open socket: #{inspect(reason)}")
    end

    listen(tcp_listener, handler)
  end

  def hand_off(port, handler) do
    socket = Socket.new(port, handler)

    with {:ok, pid} <- Controller.start(socket),
         :ok <- :gen_tcp.controlling_process(port, pid) do
      Logger.debug(
        "[#{inspect(self())}] Started Controller->#{inspect(pid)} for Port->#{inspect(port)}"
      )
    else
      _ -> Logger.error("Could not start controller for #{inspect(port)}")
    end
  end
end
