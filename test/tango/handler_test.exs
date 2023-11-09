defmodule Tango.HandlerTest do
  use ExUnit.Case, async: true

  defmodule DefaultsHandler do
    use Tango.Handler
  end

  describe "__using__" do
    test "handle_in/1 default" do
      received_string = "UnitTestABC\n"
      handled_string = DefaultsHandler.handle_in(received_string)
      assert String.trim(received_string) == handled_string
    end

    test "handle_out/1 default" do
      output_string = "UnitTestABC"
      handled_string = DefaultsHandler.handle_out(output_string)
      assert output_string <> "\n" == handled_string
    end

    test "on_connect/1 default" do
      expected_socket = "not actually a socket"
      result = DefaultsHandler.on_connect(expected_socket)
      assert {:noreply, expected_socket} == result
    end

    test "on_exit/1 default" do
      expected_socket = "not actually a socket"
      result = DefaultsHandler.on_exit(expected_socket)
      assert {:noreply, expected_socket} == result
    end

    test "handle_message/2 default" do
      expected_socket = "not actually a socket"
      result = DefaultsHandler.handle_message("not actually used", expected_socket)
      assert {:noreply, expected_socket} == result
    end

    test "handle_parse_error/3 default" do
      expected_socket = "not actually a socket"
      result = DefaultsHandler.handle_parse_error("dummy message", "dummy error", expected_socket)
      assert {:noreply, expected_socket} == result
    end
  end
end
