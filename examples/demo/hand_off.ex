defmodule Tango.Demo.HandOff do
  @moduledoc """
  A demo Tango handler that shows off changing the handler at runtime.
  """
  use Tango.Handler

  def on_connect(socket) do
    {:reply, ":: Ready.", %{ socket | handler: Tango.Demo.Mirror }}
  end
end
