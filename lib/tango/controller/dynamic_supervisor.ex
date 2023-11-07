defmodule Tango.Controller.DynamicSupervisor do
  @moduledoc false
  use DynamicSupervisor
  alias Tango.Controller

  def start(socket) do
    DynamicSupervisor.start_child(__MODULE__, {Controller, socket})
  end

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
