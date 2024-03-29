defmodule Tango.Handler do
  @moduledoc """
  Module that provides helpers for creating a Handler for Tango.

  ```elixir
  defmodule MyApp.Handler do
    use Tango.Handler
  end
  ```

  It comes out of the box with no-op functions for all of the callbacks.

  If you want some useful functionality, you'll need to provide your own logic.

  ```elixir
    def on_connect(socket) do
      {:reply, "... Send me some text", socket}
    end

    def on_exit(socket) do
      {:reply, "Have a nice day!", socket}
    end

    def handle_message(message, socket) do
      {:exit, String.reverse(message), socket}
    end
  ```

  The `handle_message/2` method is going to be the core of the handler. This callback is responsible
  for accepting and processing every message sent from the client. It also determines the response
  to send back to the client for the message.

  ```elixir
  @type reply :: {:reply, binary(), Socket.t()}
  @type no_reply :: {:noreply, Socket.t()}
  @type finish :: {:exit, binary(), Socket.t()} | {:exit, Socket.t()}
  @callback handle_message(payload :: binary(), socket :: Socket.t()) :: reply | no_reply | finish
  ```

  ```elixir
  def handle_message("mums", socket) do
    # Don't send anything back to the client
    {:noreply, socket}
  end

  def handle_message("goodbye", socket) do
    # Reply to the client with "Bye!", then close the connection
    {:exit, "Bye!", socket}
  end

  def handle_message("exit", socket) do
    # Close the connection without saying anything
    {:exit, socket}
  end

  def handle_message(message, socket) do
    # Reply to the client with the same message they sent (an echo server)
    {:reply, message, socket}
  end
  ```

  You can leverage the `handle_in/1` callback for things you want to do consistently for every
  message, such as deserialization or massaging the data.

  ```elixir
    def handle_in(message) do
      message
      |> String.trim()
      |> String.split(" ")
    end

    def handle_message(["echo", message], socket) do
      {:reply, message, socket}
    end

    def handle_message(["goodbye"], socket) do
      {:exit, "Goodbye to you, too", socket}
    end

    def handle_message(["exit"], socket) do
      {:exit, socket}
    end

    def handle_message(_, socket) do
      {:noreply, socket}
    end
  ```

  Because client input isn't always reliable, you can return `{:error, reason}` from `handle_in/1`
  which allows for not processing the input. A parse error is a no-op by default, but you can
  override `handle_parse_error/2` to change that.

  ```elixir
  def handle_in(_msg) do
    {:error, :specific_error}
  end

  def handle_parse_error(err, socket) do
    # err  == :specific_error
    Logger.error("Client \#{socket[:id]} sent invalid data: \#{inspect(err)}")
    {:noreply, socket}
  end
  ```

  You can leverage the `handle_out/1` callback to control the serialization back over the wire.

  ```elixir
    def handle_out(message) do
      Jason.encode!(message) <> "\\n"
    end
  ```

  A handler will also receive the `handle_info/2` calls you'd expect in a GenServer,
  but it will reply to the open port.

  ```elixir
    def handle_info(:ping, socket) do
      {:reply, "pong", socket}
    end

    def handle_message("ping", socket) do
      send(self(), :ping)
      {:noreply, socket}
    end
  ```

  The handler is set at runtime, so you can actually swap out a socket's handler depending
  on your needs. The new module only needs to be sure to implement the `Tango.Handler` callbacks.


  ```elixir
  def handle_message(["#swap", "mirror"]) do
    {:noreply, %{ socket | handler: Tango.Demo.Mirror }}
  end
  ```
  """

  alias Tango.Socket

  @type reply :: {:reply, binary(), Socket.t()}
  @type no_reply :: {:noreply, Socket.t()}
  @type finish :: {:exit, binary(), Socket.t()} | {:exit, Socket.t()}

  @callback on_connect(socket :: Socket.t()) :: reply | no_reply | finish
  @callback on_exit(socket :: Socket.t()) :: reply | no_reply | finish
  @callback handle_message(payload :: binary(), socket :: Socket.t()) :: reply | no_reply | finish
  @callback handle_parse_error(message :: term(), error :: term(), socket :: Socket.t()) ::
              reply | no_reply | finish

  @callback handle_out(term()) :: term()
  @callback handle_in(term()) :: term() | {:error, term()}

  defmacro __using__(_) do
    quote do
      @behaviour Tango.Handler
      import Tango.Handler

      def on_connect(socket), do: {:noreply, socket}
      def on_exit(socket), do: {:noreply, socket}
      def handle_in(message), do: String.trim(message)
      def handle_out(message), do: message <> "\n"
      def handle_message(_message, socket), do: {:noreply, socket}
      def handle_parse_error(_message, _error, socket), do: {:noreply, socket}

      defoverridable on_connect: 1,
                     on_exit: 1,
                     handle_out: 1,
                     handle_in: 1,
                     handle_message: 2,
                     handle_parse_error: 3
    end
  end

  defdelegate assign(socket, assigns), to: Socket
  defdelegate assign(socket, key, value), to: Socket
  defdelegate unassign(socket, key), to: Socket
end
