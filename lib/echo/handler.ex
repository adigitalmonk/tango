defmodule Echo.Handler do
  alias Echo.Socket

  @type reply :: {:reply, binary(), Socket.t()}
  @type no_reply :: {:noreply, Socket.t()}
  @type finish ::
          {:reply_exit, binary(), Socket.t()}
          | {:exit, Socket.t()}

  @callback on_connect(socket :: Socket.t()) :: reply | no_reply | finish
  @callback on_exit(socket :: Socket.t()) :: reply | no_reply | finish
  @callback handle_message(payload :: binary(), socket :: Socket.t()) ::
              reply | no_reply | finish

  defmacro __using__(_) do
    quote do
      @behaviour Echo.Handler
      import Echo.Handler

      def serialize(message), do: message <> "\n"
      def deserialize(message), do: String.trim(message)

      defoverridable serialize: 1, deserialize: 1
    end
  end

  def assign(socket, assigns) when is_map(assigns),
    do: %{socket | assigns: Map.merge(socket.assigns, assigns)}

  def assign(socket, key, value),
    do: %{socket | assigns: Map.put(socket.assigns, key, value)}

  def unassign(socket, key),
    do: %{socket | assigns: Map.drop(socket.assigns, [key])}
end
