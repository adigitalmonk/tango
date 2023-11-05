defmodule Echo.Handler do
  alias Echo.Socket

  @type reply :: {:reply, binary(), Socket.t()}
  @type no_reply :: {:noreply, Socket.t()}
  @type finish :: {:exit, binary(), Socket.t()} | {:exit, Socket.t()}

  @callback on_connect(socket :: Socket.t()) :: reply | no_reply | finish
  @callback on_exit(socket :: Socket.t()) :: reply | no_reply | finish
  @callback handle_message(payload :: binary(), socket :: Socket.t()) :: reply | no_reply | finish

  @callback handle_out(term()) :: term()
  @callback handle_in(term()) :: term() | {:error, term()}

  defmacro __using__(_) do
    quote do
      @behaviour Echo.Handler
      import Echo.Handler

      def handle_in(message), do: String.trim(message)
      def handle_out(message), do: message <> "\n"

      defoverridable handle_out: 1, handle_in: 1
    end
  end

  defdelegate assign(socket, assigns), to: Socket
  defdelegate assign(socket, key, value), to: Socket
  defdelegate unassign(socket, key), to: Socket
end
