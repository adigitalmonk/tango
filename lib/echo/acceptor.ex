defmodule Echo.Acceptor do
  alias Echo.{Controller, Socket}
  require Logger

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
      Logger.debug("#{inspect(self())} Start/Controller->#{inspect(pid)}/Port->#{inspect(port)}")
    else
      _ -> Logger.error("Could not start controller for #{inspect(port)}")
    end
  end
end
