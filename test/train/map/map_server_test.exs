defmodule Train.Map.MapServerTest do
  use ExUnit.Case, async: true

  alias Train.Map.Map
  alias Train.Map.Section
  alias Train.Map.Vehicle
  alias Train.Map.Signal

  alias Train.Map.MapServer

  alias TrainTest.AlwaysAdvance

  @sectionA Section.new("A", "B")
  @sectionB Section.new("B", "A")
  @vehicle Vehicle.new("A", AlwaysAdvance)
  @signal Signal.at_stop("A")
  @test_map Map.new([@sectionA, @sectionB], [@vehicle], [@signal])

  setup do
    map_server = start_supervised!({MapServer, @test_map})
    %{map_server: map_server}
  end

  describe "read" do
    test "returns tiles" do
      assert(MapServer.read() == [
        %{location: "A", signal: %{state: :stop, has_turnout: false}, vehicle: %{distance_to_next_section: 100, location: "A", max_acceleration: 10, max_speed: 50, speed: 0}},
        %{location: "B"}
      ])
    end
  end

  describe "tick" do
    test "advances to next state" do
      MapServer.tick()
      assert(MapServer.read() == [
        %{location: "A", signal: %{state: :stop, has_turnout: false}},
        %{location: "B", vehicle: %{distance_to_next_section: 100, location: "B", max_acceleration: 10, max_speed: 50, speed: 0}}
      ])
    end
  end

  describe "toggle_signal" do
    test "toggles given signal state" do
      MapServer.toggle_signal("A")
      assert(MapServer.read() == [
        %{location: "A", signal: %{state: :clear, has_turnout: false}, vehicle: %{distance_to_next_section: 100, location: "A", max_acceleration: 10, max_speed: 50, speed: 0}},
        %{location: "B"}
      ])
    end
  end

  describe "reset" do
    test "returns to original state" do
      MapServer.toggle_signal("A")
      MapServer.tick()
      MapServer.reset()
      assert(MapServer.read() == [
        %{location: "A", signal: %{state: :stop, has_turnout: false}, vehicle: %{distance_to_next_section: 100, location: "A", max_acceleration: 10, max_speed: 50, speed: 0}},
        %{location: "B"}
      ])
    end
  end
end
