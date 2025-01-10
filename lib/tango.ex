defmodule Tango do
  @moduledoc """
  The base module for Tango.

  Configuration is handled via passing it in your application configuration.

  ```elixir
  def start(_type, _args) do
    children = [
      {Tango, port: 3000, handler: MyApp.MyHandler}
    ]

    # ...
  ```

  Tango supports the following configuration options:

  - `:port`
    - The port to listen to connections on. (optional, defaults to 4040)
  - `:handler`
    - A module that implements the `Tango.Handler` behaviour. (required)
  - `:pool_size`
    - The number of processes to listen for connections on. (optional, defaults to 1)
  - `:packet`
    - This is the packet type to expect on the connection. (optional, defaults to `:line`)
    - <https://www.erlang.org/doc/apps/kernel/gen_tcp.html#t:option/0>
    `:receive_as`
    - This is the way that payloads are interpreted from clients.
    - Can either be `:list` for bytes (char lists) or `:binary` (default) for binaries (strings)
  """

  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  defp put_tango_defaults(opts) do
    opts =
      opts
      |> Keyword.put_new(:port, 4000)
      |> Keyword.put_new(:pool_size, 1)
      |> Keyword.put_new(:packet, :line)
      |> Keyword.put_new(:receive_as, :binary)

    Logger.debug("Starting Tango using: #{inspect(opts)}")

    opts
  end

  @impl Supervisor
  def init(opts \\ []) do
    opts = put_tango_defaults(opts)

    children = [
      Tango.Controller.DynamicSupervisor,
      {Task.Supervisor, name: Tango.Acceptor},
      {Tango.Init, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
