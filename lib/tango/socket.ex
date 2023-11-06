defmodule Tango.Socket do
  @type t :: %__MODULE__{}
  defstruct [:id, :port, :handler, :assigns]

  def new(port, handler) do
    %__MODULE__{
      id: make_ref(),
      port: port,
      handler: handler,
      assigns: %{}
    }
  end

  def assign(socket, assigns) when is_map(assigns),
    do: %{socket | assigns: Map.merge(socket.assigns, assigns)}

  def assign(socket, key, value),
    do: %{socket | assigns: Map.put(socket.assigns, key, value)}

  def unassign(socket, key),
    do: %{socket | assigns: Map.drop(socket.assigns, [key])}
end
