defmodule Tango.Demo.Reverse do
  @moduledoc """
  A demo Tango handler that accepts a string, reverses it,
  sends it back, the closes the connection.
  """
  use Tango.Handler

  def on_connect(socket) do
    {:reply, "... Send me some text", socket}
  end

  def on_exit(socket) do
    {:reply, "Have a nice day!", socket}
  end

  def handle_message(message, socket) do
    response =
      message
      |> String.trim()
      |> String.reverse()

    {:exit, response, socket}
  end
end
