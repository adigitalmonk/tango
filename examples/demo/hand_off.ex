defmodule Echo.Demo.HandOff do
  @moduledoc """
  A demo Echo handler that shows off changing the handler at runtime.
  """
  use Echo.Handler

  def on_connect(socket) do
    {:reply, ":: Ready.", %{ socket | handler: Echo.Demo.Mirror }}
  end
end
