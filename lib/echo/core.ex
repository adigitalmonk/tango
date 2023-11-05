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
    opts
    |> Keyword.put_new(:handler, Echo.Demo.Reverse)
    |> Keyword.put_new(:packet, :line)
    |> Keyword.put_new(:port, 4040)
  end

  def start_link(opts) do
    opts = put_defaults(opts)
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    {:ok, opts, {:continue, :start}}
  end

  def handle_continue(:start, opts) do
    handler = opts[:handler] || Echo.Demo.Reverse
    port = opts[:port] || 4040
    pool_size = opts[:pool_size] || 10

    listen_conf =
      @listen_defaults
      |> Keyword.merge((opts[:listen_conf] || []))

    {:ok, tcp_listener} = :gen_tcp.listen(port, listen_conf)

    Enum.each(1..pool_size, fn _ ->
      Echo.Acceptor.start(tcp_listener, handler)
    end)

    Logger.debug("Started #{pool_size} listeners on port #{port}")

    {:noreply, opts}
  end
end
