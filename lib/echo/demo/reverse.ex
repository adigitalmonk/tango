defmodule Echo.Demo.Reverse do
  use Echo.Handler

  def on_connect(socket) do
    respond("... Send me some text\n", socket)
  end

  def on_exit(_socket) do
    :ok
  end

  def handle(raw, socket) do
    raw
    |> String.trim()
    |> String.reverse()
    |> Kernel.<>("\n")
    |> respond(socket)

    :close
  end
end
