defmodule Echo do
  alias Echo.Controller
  require Logger

  def accept(port, opts \\ []) do
    handler = opts[:handler] || Echo.Demo.Reverse
    packet = opts[:packet] || :line

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: packet, active: true, reuseaddr: true])

    loop_acceptor(socket, handler)
  end

  defp loop_acceptor(socket, handler) do
    socket
    |> :gen_tcp.accept()
    |> hand_off(handler)

    loop_acceptor(socket, handler)
  end

  def hand_off({:ok, client}, handler) do
    {:ok, pid} = Controller.start(client, handler)
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  def hand_off({:error, reason}, _handler) do
    Logger.error("Couldn't open socket: #{inspect(reason)}")
  end
end
