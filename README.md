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
