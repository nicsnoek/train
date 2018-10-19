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
  end

  describe "next_state" do

    defmodule AlwaysAdvance do
      @behaviour MovementModel
      def next_state(vehicle, sections, _signals_by_location) do
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

  end
end

