defmodule Tango.Socket do
  @moduledoc """
  The structure used to store the important parts of a connection
  for use in the Handler.
  """
  @type t :: %__MODULE__{}
  defstruct [:id, :port, :handler, :assigns]

  @doc false
  def new(port, handler) do
    %__MODULE__{
      id: make_ref(),
      port: port,
      handler: handler,
      assigns: %{}
    }
  end

  @doc """
  Stores persistent data between handler messages.

  Accepts a map of keys that will get merged into the current `assigns`.
  """
  def assign(socket, assigns) when is_map(assigns),
    do: %{socket | assigns: Map.merge(socket.assigns, assigns)}

  @doc """
  Stores persistent data between handler messages.

  Accepts a single key and value that will replace the current value in `assigns`.
  """
  def assign(socket, key, value),
    do: %{socket | assigns: Map.put(socket.assigns, key, value)}

  @doc """
  Removes a key or keys from the Socket's persistent storage.
  """
  def unassign(socket, keys) when is_list(keys),
    do: %{socket | assigns: Map.drop(socket.assigns, keys)}

  def unassign(socket, key),
    do: %{socket | assigns: Map.drop(socket.assigns, [key])}
end
