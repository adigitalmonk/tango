defmodule Echo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children() do
    port =
      System.get_env("LISTEN_PORT", "4040")
      |> String.to_integer()

    [
      Echo.Controller.supervisor(),
      Supervisor.child_spec(
        {Task, fn -> Echo.accept(port) end},
        restart: :permanent
      )
    ]
  end
end
