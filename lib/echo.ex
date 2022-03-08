defmodule Echo do
  use GenServer, restart: :permanent

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
    packet = opts[:packet] || :line
    port = opts[:port] || 4040
    pool_size = opts[:pool_size] || 10

    listen_conf = [:binary, packet: packet, active: true, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, listen_conf)

    Enum.each(0..pool_size, fn _ ->
      Echo.Acceptor.start(socket, handler)
    end)

    {:noreply, opts}
  end
end
