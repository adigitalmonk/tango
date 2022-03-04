defmodule Echo.Demo.Mirror do
  use Echo.Handler

  def on_connect(socket) do
    respond("... Connected!\n", socket)
  end

  def on_exit(socket) do
    respond("... Closing!\n", socket)
  end

  def handle(raw, socket) do
    raw
    |> String.trim()
    |> case do
      <<"exit", _::binary>> ->
        :close

      message ->
        message
        |> Kernel.<>("\n")
        |> respond(socket)
    end
  end
end
