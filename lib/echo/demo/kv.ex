defmodule Echo.Demo.KV do
  use Echo.Handler

  def on_connect(socket) do
    {:reply, ":: Ready.", socket}
  end

  def on_exit(socket) do
    {:reply, ":: Goodbye.", socket}
  end

  def handle_message(message, %{assigns: assigns} = socket) do
    message
    |> String.split("|")
    |> case do
      ["PUT", key, value | _] ->
        socket = assign(socket, key, value)
        {:reply, ":: OK", socket}

      ["LIST" | _] ->
        keys =
          assigns
          |> Map.keys()
          |> Enum.join("|")

        {:reply, ":: KEYS -> " <> keys, socket}

      ["GET", key | _] ->
        response =
          case assigns[key] do
            nil -> ":: Not Found"
            value -> ":: VALUE -> " <> value
          end

        {:reply, response <> "", socket}

      ["DROP", key | _] ->
        socket = unassign(socket, key)
        {:reply, ":: OK", socket}

      ["EXIT" | _] ->
        {:exit, socket}

      _ ->
        {:reply, ":: Unrecognized Command", socket}
    end
  end
end
