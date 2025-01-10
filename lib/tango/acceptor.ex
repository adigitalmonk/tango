defmodule Tango.Acceptor do
  @moduledoc false
  alias Tango.{Controller, Socket}
  require Logger

  def start_pool(pool_size, tcp_listener, handler) do
    Enum.each(1..pool_size, fn _ ->
      Task.Supervisor.start_child(
        __MODULE__,
        fn -> listen(tcp_listener, handler) end,
        restart: :temporary
      )
    end)
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
      Logger.debug("#{inspect(self())} Start/Controller->#{inspect(pid)}/Port->#{inspect(port)}")
    else
      _ -> Logger.error("Could not start controller for #{inspect(port)}")
    end
  end
end
