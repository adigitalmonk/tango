defmodule Echo.Core do
  use GenServer, restart: :permanent
  require Logger

  @listen_defaults [
    :binary,
    packet: :line,
    active: true,
    reuseaddr: true
  ]

  defp put_defaults(opts) do
    Keyword.put_new(opts, :port, 2323)
  end

  def start_link(opts) do
    opts = put_defaults(opts)
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    {:ok, opts, {:continue, :start}}
  end

  def handle_continue(:start, opts) do
    handler = opts[:handler] || raise "??"
    port = opts[:port]
    pool_size = opts[:pool_size] || 1

    listen_conf =
      Keyword.merge(@listen_defaults, opts[:listen_conf] || [])

    {:ok, tcp_listener} = :gen_tcp.listen(port, listen_conf)

    Echo.Acceptor.TaskSupervisor.start_pool(
      pool_size,
      tcp_listener,
      handler
    )

    Logger.debug("Started #{pool_size} listeners on port #{inspect(port)}")

    {:noreply, opts}
  end
end
