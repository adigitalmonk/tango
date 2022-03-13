defmodule Echo do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    port = Application.get_env(:echo, :port, 4040)
    handler = Application.get_env(:echo, :handler, Echo.Demo.KV)

    echo_opts = [handler: handler, port: port]

    children = [
      Echo.Controller.supervisor(),
      {Task.Supervisor, name: Echo.TaskSupervisor},
      {Echo.Core, echo_opts}
    ]

    supervisor_opts = Keyword.merge(opts, strategy: :one_for_one, name: Echo.Supervisor)
    Supervisor.init(children, supervisor_opts)
  end
end
