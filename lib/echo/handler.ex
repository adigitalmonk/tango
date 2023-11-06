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

      def on_connect(socket), do: {:noreply, socket}
      def on_exit(socket), do: {:noreply, socket}
      def handle_in(message), do: String.trim(message)
      def handle_out(message), do: message <> "\n"
      def handle_message(_message, socket), do: {:noreply, socket}

      defoverridable on_connect: 1, on_exit: 1, handle_out: 1, handle_in: 1, handle_message: 2
    end
  end

  defdelegate assign(socket, assigns), to: Socket
  defdelegate assign(socket, key, value), to: Socket
  defdelegate unassign(socket, key), to: Socket
end
