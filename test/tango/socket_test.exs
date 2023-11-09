defmodule Tango.SocketTest do
  use ExUnit.Case, async: true
  alias Tango.Socket

  describe "sockets and their unique ids" do
    test "are always unique" do
      ids =
        Enum.reduce(0..9, MapSet.new(), fn _, set ->
          socket = Socket.new(nil, nil)
          MapSet.put(set, socket.id)
        end)

      assert Enum.count(ids) == 10
    end
  end

  describe "assigning data to sockets" do
    test "accepts a key/value set" do
      expected_key = "expected_key"
      expected_value = "expected_value"

      socket =
        Socket.new(nil, nil)
        |> Socket.assign("expected_key", "expected_value")

      assert socket.assigns[expected_key] == expected_value
      assert Map.get(socket.assigns, expected_key) == expected_value
    end

    test "accepts a map of keys and values" do
      expected_data = %{
        test: "value",
        test2: "value2"
      }

      socket =
        Socket.new(nil, nil)
        |> Socket.assign(expected_data)

      assert socket.assigns == expected_data
    end

    test "overwrites existing data with key/value pairs" do
      socket =
        Socket.new(nil, nil)
        |> Socket.assign("key", "value")
        |> Socket.assign("key", "replaced")

      assert socket.assigns["key"] == "replaced"
    end

    test "overwrites existing data with new map keys" do
      initial_data = %{
        test: "value",
        test2: "value2"
      }

      replacement_data = %{
        test: "replaced"
      }

      socket =
        Socket.new(nil, nil)
        |> Socket.assign(initial_data)
        |> Socket.assign(replacement_data)

      assert socket.assigns == Map.merge(initial_data, replacement_data)
    end

    test "can be forgotten" do
      socket =
        Socket.new(nil, nil)
        |> Socket.assign("key", "test")

      assert socket.assigns["key"] == "test"

      socket = Socket.unassign(socket, "key")

      assert socket.assigns["key"] == nil
    end
  end
end
