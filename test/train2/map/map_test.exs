defmodule Train2.Map.MapTest do
  use Train2.DataCase

  alias Train2.Map.Map
  alias Train2.Map.Section
  alias Train2.Map.Vehicle
  alias Train2.Map.Signal

  @sectionA Section.new("A", "B")
  @sectionB Section.new("B", "A")

  describe "as_tiles" do
    test "converts basic map to tiles" do
      sections = [@sectionA, @sectionB]
      map = Map.new(sections, [], [])
      tiles = Map.as_tiles(map)
      assert(tiles == [%{location: "A"}, %{location: "B"}])
    end

    test "converts map with vehicle to tiles" do
      sections = [@sectionA, @sectionB]
      vehicle = Vehicle.new("A")
      map = Map.new(sections, [vehicle], [])
      tiles = Map.as_tiles(map)
      assert(tiles == [%{location: "A", vehicle: vehicle}, %{location: "B"}])
    end

    test "converts map with signal to tiles" do
      sections = [@sectionA, @sectionB]
      signal = Signal.at_stop("A")
      map = Map.new(sections, [], [signal])
      tiles = Map.as_tiles(map)
      assert(tiles == [%{location: "A", signal: signal}, %{location: "B"}])
    end
  end

  describe "next_state" do

    defmodule AlwaysAdvance do
      @behaviour MovementModel
      def next_state(vehicle, sections, _signals) do
        section_with_vehicle = Enum.find(sections, fn section -> section.from == vehicle.location end)
        %{vehicle | location: section_with_vehicle.to}
      end
    end

    test "advances vehicle to next section as determined by the movement model" do
      sections = [@sectionA, @sectionB]
      vehicle = Vehicle.new("A", AlwaysAdvance)
      map = Map.new(sections, [vehicle], [])
      next_state = Map.next_state(map)
      assert(next_state == Map.new(sections, [Vehicle.new("B", AlwaysAdvance)], []))
      next_state = Map.next_state(next_state)
      assert(next_state == Map.new(sections, [Vehicle.new("A", AlwaysAdvance)], []))
    end

    test "makes signal go to stop when vehicle enters section" do
      sections = [Section.new("A", "B"), Section.new("B", "C"), Section.new("C", "A")]
      signalA = Signal.new("A", Signal.clear())
      signalC = Signal.new("C", Signal.clear())
      vehicle = Vehicle.new("B", AlwaysAdvance)
      map = Map.new(sections, [vehicle], [signalA, signalC])
      assert(Signal.at(map.signals, "A").state == Signal.clear())
      assert(Signal.at(map.signals, "C").state == Signal.clear())
      next_state = Map.next_state(map)
      assert(Signal.at(next_state.signals, "A").state == Signal.clear())
      assert(Signal.at(next_state.signals, "C").state == Signal.stop())
    end
  end

  describe "toggle_signal" do
    test "it clears signal at stop at given location and does not affect signals at other locations" do
      sections = [Section.new("A", "B"), Section.new("B", "C"), Section.new("C", "A")]
      signalA = Signal.new("A", Signal.stop())
      signalC = Signal.new("C", Signal.stop())
      map = Map.new(sections, [], [signalA, signalC])
      new_map = Map.toggle_signal(map, "C")
      assert(Signal.at(new_map.signals, "A").state == Signal.stop())
      assert(Signal.at(new_map.signals, "C").state == Signal.clear())
    end

    test "it stops signal at clear at given location and does not affect signals at other locations" do
      sections = [Section.new("A", "B"), Section.new("B", "C"), Section.new("C", "A")]
      signalA = Signal.new("A", Signal.clear())
      signalC = Signal.new("C", Signal.clear())
      map = Map.new(sections, [], [signalA, signalC])
      new_map = Map.toggle_signal(map, "C")
      assert(Signal.at(new_map.signals, "A").state == Signal.clear())
      assert(Signal.at(new_map.signals, "C").state == Signal.stop())
    end
  end
end

