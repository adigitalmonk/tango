defmodule Echo.Socket do
  @type t :: %__MODULE__{}
  defstruct [:id, :port, :handler, :assigns]
end
