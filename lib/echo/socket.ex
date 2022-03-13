defmodule Echo.Socket do
  @type t :: %__MODULE__{}
  # TODO: some unique identifier?
  defstruct [:port, :handler, :assigns]
end
