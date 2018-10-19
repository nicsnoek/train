defmodule Train2.Map.Map do
  @moduledoc false

  alias Train2.Map.Vehicle
  alias Train2.Map.Tile

  defstruct sections: [], vehicles_by_location: nil, signals_by_location: nil

  def new(sections) do
    new(sections, [], [])
  end

  defp by_location(list) do
    Enum.reduce(list, %{}, fn (item, acc) -> Map.put(acc, item.location, item) end)
  end

  def new(sections, vehicles, signals) do
    vehicles_by_location = by_location(vehicles)
    signals_by_location = by_location(signals)
    %__MODULE__{
      sections: sections,
      vehicles_by_location: vehicles_by_location,
      signals_by_location: signals_by_location
    }
  end

  def as_tiles(map) do
    Enum.map(
      map.sections,
      fn section ->
        v = Map.get(map.vehicles_by_location, section.from)
        if v do
          Tile.occupied_with(section.from, v)
        else
          Tile.at(section.from)
        end
      end
    )
  end

  def next_state(map) do
    vehicles = Map.values(map.vehicles_by_location)
    next_state_vehicles = Enum.map(vehicles, fn v -> Vehicle.next_state(v, map.sections, map.signals_by_location) end)
    new(map.sections, next_state_vehicles, Map.values(map.signals_by_location))
  end

end
