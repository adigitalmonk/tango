# Echo

A simple tool for accepting TCP connections and handing them off to a connection
handler.

## Installation

Echo is in alpha. If you wanna try it out though, you can install it via git:

```elixir
  def deps do
    [
        {:echo, github: "adigitalmonk/echo", branch: "main"}
    ]
  end
```

## Usage

Configuration Options

```elixir
defmodule MyApp.MyEcho do
    use Echo, 
        port: 4040,
        handler: Echo.Demo.KV,
        pool_size: 5
end
```

Pass in configuration via...

- <https://hexdocs.pm/elixir/1.12/Supervisor.html#init/2>

```elixir
def start(_type, _args) do
    children = [
        MyApp.MyEcho
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
end
```

### Serialization / Deserialization

By default, Echo will serialize only strings and will simply append a `\n`.
The default deserialization will take the payload and `String.trim/1` any whitespace.
You can replace this behavior easily in your handler by overriding the default methods.

- `serialize/1` should receive a message to send back to the client and format it appropriately.

- `deserialize/1` should receive a raw message from the client and then marshal it for the application.
 - You can also return an error tuple `{:error, reason}` from `deserialize/1`.
 - This will not respond to the client, but will display an error log in the server's console.

```elixir
defmodule MyApp.MyHandler do
  def serialize(message), do: Jason.encode!(message) <> "\n"
  def deserialize(message), do: message |> String.trim() |> Jason.decode()
end
```
