defmodule Train2.Map.Map do
  @moduledoc false

  alias Train2.Map.Vehicle
  alias Train2.Map.Tile
  alias Train2.Map.Signal

  defstruct initial_state: nil, sections: [], vehicles_by_location: nil, signals: nil

  def new(sections) do
    new(sections, [], [])
  end

  defp by_location(list) do
    Enum.reduce(list, %{}, fn (item, acc) -> Map.put(acc, item.location, item) end)
  end

  def new(sections, vehicles, signals) do
    vehicles_by_location = by_location(vehicles)
    map = %__MODULE__{
      sections: sections,
      vehicles_by_location: vehicles_by_location,
      signals: Signal.signals(signals)
    }
    %{map| initial_state: map}
  end

  def reset(map) do
    initial_state = map.initial_state
    %{initial_state| initial_state: initial_state}
  end

  def as_tiles(map) do
    Enum.map(
      map.sections,
      fn section ->
        v = Map.get(map.vehicles_by_location, section.from)
        s = Signal.at(map.signals, section.from)
        Tile.occupied_with(section.from, v, s)
      end
    )
  end

  defp next_vehicle_states(map) do
    Map.values(map.vehicles_by_location)
    |> Enum.map(fn v -> Vehicle.next_state(v, map.sections, map.signals) end)
    |> by_location
  end

  def next_state(map) do
    next_state_vehicles_by_location = next_vehicle_states(map)
    next_signals = Signal.set_occupied_locations_to_stop(map.signals, Map.keys(next_state_vehicles_by_location))
    %{map | vehicles_by_location: next_state_vehicles_by_location, signals: next_signals}
  end

  def signal_at_location(map, location) do
    map.signals |> Signal.at(location)
  end

  def toggle_signal(map, location) do
    signal = map.signals |> Signal.at(location)
    if signal == nil do
        map
      else
        %{map | signals: Signal.toggle_signal(map.signals, location)}
    end
  end

end
