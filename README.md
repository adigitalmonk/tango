# Tango 💃

A simple tool for accepting TCP connections and handing them off to a provided connection handler.

## Installation

Tango is in alpha. If you wanna try it out though, you can install it via git:

```elixir
  def deps do
    [
        {:tango, github: "adigitalmonk/tango", branch: "main"}
    ]
  end
```

## Usage

Tango relies on a handler to connect handle incoming messages.

A very simple "no-op" handler is simply:

```elixir
defmodule MyApp.Handler do
  use Tango.Handler
end
```

The default callbacks are implemented as:

```elixir
  def on_connect(socket), do: {:noreply, socket}
  def on_exit(socket), do: {:noreply, socket}
  def handle_in(message), do: String.trim(message)
  def handle_out(message), do: message <> "\n"
  def handle_message(_message, socket), do: {:noreply, socket}
```

Refer to the Tango.Handler `@moduledoc` for more information on the handlers and what they can do.

There are a few example handlers in the [Examples folder](./examples/).

### Configuration Options

Pass in configuration via the child_spec.

```elixir
def start(_type, _args) do
  children = [
    {Tango, handler: MyApp.MyHandler}
  ]

  # ...
```

See the `Tango` module doc for more information.

### Listener Pool

// To Do


### Serialization / Deserialization

By default, Tango will serialize only strings and will simply append a `\n`.
The default deserialization will take the payload and `String.trim/1` any whitespace.
You can replace this behavior easily in your handler by overriding the default methods.

- `handle_out/1` should receive a message to send back to the client and format it appropriately.

- `handle_in/1` should receive a raw message from the client and then marshal it for the application.
 - You can also return an error tuple `{:error, reason}` from `handle_in/1`.
 - This will not respond to the client, but will display an error log in the server's console.

```elixir
defmodule MyApp.MyHandler do
  # ...

  def handle_out(message) do
    Jason.encode!(message) <> "\n"
  end

  def handle_in(message) do
    message
    |> String.trim()
    |> Jason.decode()
  end

  # ...
end
```
