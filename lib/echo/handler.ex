defmodule Echo.Handler do
  alias Echo.Socket

  @type reply :: {:reply, binary(), Socket.t()}
  @type no_reply :: {:noreply, Socket.t()}
  @type finish :: {:exit, binary(), Socket.t()} | {:exit, Socket.t()}

  @callback on_connect(socket :: Socket.t()) :: reply | no_reply | finish
  @callback on_exit(socket :: Socket.t()) :: reply | no_reply | finish
  @callback handle_message(payload :: binary(), socket :: Socket.t()) :: reply | no_reply | finish

  @callback serialize(binary()) :: term()
  @callback deserialize(term()) :: binary() | {:error, term()}

  defmacro __using__(_) do
    quote do
      @behaviour Echo.Handler
      import Echo.Handler

      def serialize(message), do: message <> "\n"
      def deserialize(message), do: String.trim(message)

      defoverridable serialize: 1, deserialize: 1
    end
  end

  defdelegate assign(socket, assigns), to: Socket
  defdelegate assign(socket, key, value), to: Socket
  defdelegate unassign(socket, key), to: Socket
end
