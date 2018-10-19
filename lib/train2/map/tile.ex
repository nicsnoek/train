defmodule Train2.Map.Tile do
  @moduledoc false

  def occupied_with(location, vehicle) do
    %{
      location: location,
      vehicle: vehicle
    }
  end

  def at(location) do
    %{ location: location }
  end

end
