defmodule Tango.Core do
  @moduledoc false
  use GenServer, restart: :permanent
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    {:ok, opts, {:continue, :start}}
  end

  def handle_continue(:start, opts) do
    handler = opts[:handler]
    port = opts[:port]
    pool_size = opts[:pool_size]
    packet = opts[:packet]

    {:ok, tcp_listener} =
      :gen_tcp.listen(port, [
        :binary,
        packet: packet,
        active: true,
        reuseaddr: true
      ])

    Tango.Acceptor.start_pool(
      pool_size,
      tcp_listener,
      handler
    )

    Logger.debug("Started #{pool_size} listeners on port #{inspect(port)}")

    {:noreply, opts}
  end
end
