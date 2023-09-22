defmodule Echo.Demo.Reverse do
  use Echo.Handler

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
