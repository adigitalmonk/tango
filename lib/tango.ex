defmodule Tango do
  defmacro __using__(opts) do
    server_port = Keyword.get(opts, :port, 4040)
    connection_handler = Keyword.get(opts, :handler) || raise "Missing required Handler"
    packet_type = Keyword.get(opts, :packet, :line)
    pool_size = Keyword.get(opts, :pool_size, 1)

    quote do
      use Supervisor

      def start_link(opts \\ []) do
        name = Keyword.get(opts, :name, __MODULE__)
        Supervisor.start_link(__MODULE__, opts, name: name)
      end

      @impl true
      def init(opts) do
        tango_opts = [
          handler: unquote(connection_handler),
          port: unquote(server_port),
          packet: unquote(packet_type),
          pool_size: unquote(pool_size)
        ]

        children = [
          Tango.Controller.DynamicSupervisor,
          {Task.Supervisor, name: Tango.Acceptor.TaskSupervisor},
          {Tango.Core, tango_opts}
        ]

        supervisor_opts =
          [
            strategy: :one_for_one
          ]
          |> Keyword.merge(opts)

        Supervisor.init(children, supervisor_opts)
      end
    end
  end
end