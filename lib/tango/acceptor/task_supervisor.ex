defmodule Tango.Acceptor.TaskSupervisor do
  @moduledoc false
  alias Tango.Acceptor

  def start_pool(pool_size, tcp_listener, handler) do
    Enum.each(1..pool_size, fn _ ->
      Task.Supervisor.start_child(
        __MODULE__,
        fn -> Acceptor.listen(tcp_listener, handler) end,
        restart: :temporary
      )
    end)
  end
end
