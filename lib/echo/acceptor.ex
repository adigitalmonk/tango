defmodule Echo.Acceptor do
  alias Echo.Controller
  require Logger

  @supervisor __MODULE__.TaskSupervisor
  def supervisor, do: {Task.Supervisor, name: @supervisor}

  def start(socket, handler) do
    {:ok, _pid} =
      Task.Supervisor.start_child(
        @supervisor,
        fn -> listen(socket, handler) end,
        restart: :temporary
      )
  end

  def listen(socket, handler) do
    socket
    |> :gen_tcp.accept()
    |> hand_off(handler)

    listen(socket, handler)
  end

  def hand_off({:ok, client}, handler) do
    {:ok, pid} = Controller.start(client, handler)
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  def hand_off({:error, reason}, _handler) do
    Logger.error("Couldn't open socket: #{inspect(reason)}")
  end
end
