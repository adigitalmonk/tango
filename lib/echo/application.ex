defmodule Echo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:echo, :port, 4040)
    handler = Application.get_env(:echo, :handler, Echo.Demo.KV)

    echo_opts = [
      handler: handler,
      port: port
    ]

    children = [
      Echo.Controller.supervisor(),
      {Task.Supervisor, name: Echo.TaskSupervisor},
      {Echo, echo_opts}
    ]

    supervisor_opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children, supervisor_opts)
  end
end
