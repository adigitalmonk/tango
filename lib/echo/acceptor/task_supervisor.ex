defmodule Echo.Acceptor.TaskSupervisor do
  alias Echo.Acceptor

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
