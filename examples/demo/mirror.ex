defmodule Tango.Demo.Mirror do
  @moduledoc """
  A demo Tango handler that accepts some simple commands
  """
  use Tango.Handler

  def on_connect(socket), do: {:reply, "... Connected!", socket}
  def on_exit(socket), do: {:reply, "... Closing!", socket}

  def handle_message(<<"exit", _::binary>>, socket), do: {:exit, socket}
  def handle_message(<<"skip", _::binary>>, socket), do: {:noreply, socket}

  def handle_message(<<"magic", _::binary>>, socket),
    do: {:exit, "This is a magic free zone!", socket}

  def handle_message(<<"reverse|", rest::binary>>, socket),
    do: {:reply, String.reverse(rest), socket}

  def handle_message(message, socket), do: {:reply, message, socket}
end
