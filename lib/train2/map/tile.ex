defmodule Train2.Map.Tile do
  @moduledoc false

  alias Train2.Map.Vehicle
  alias Train2.Map.Signal

  defp with_vehicle(tile, vehicle) do
    if vehicle do
      Map.put(tile, :vehicle, Vehicle.as_tile(vehicle))
    else
      tile
    end
  end

  defp with_signal(tile, signal) do
    if signal do
      Map.put(tile, :signal, Signal.as_tile(signal))
    else
      tile
    end
  end

  def occupied_with(location, vehicle, signal) do
    tile = %{
      location: location,
    }
    tile |> with_vehicle(vehicle) |> with_signal(signal)
  end

end
