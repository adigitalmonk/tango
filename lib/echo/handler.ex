defmodule Echo.Handler do
  @callback on_connect(socket :: :gen_tcp.socket()) :: :ok
  @callback on_exit(socket :: :gen_tcp.socket()) :: :ok
  @callback handle(payload :: binary(), socket :: :gen_tcp.socket()) :: :ok | :close

  defmacro __using__(_) do
    quote do
      @behaviour Echo.Handler
      import Echo.Handler
    end
  end

  def respond(message, socket) do
    :gen_tcp.send(socket, message)
  end
end
