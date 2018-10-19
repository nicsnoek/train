defmodule Train2.Map.Vehicle do
  @moduledoc false

  defstruct location: nil,
            movement_model: nil,
            speed: 0,
            distance_to_next_section: 100, # initialised to section length
            max_speed: 50,
            max_acceleration: 10

  def new(location, movement_model \\ DefaultMovementModel) do
    %__MODULE__{
      location: location,
      movement_model: movement_model,
    }
  end

  def next_state(vehicle, sections, signals_by_location \\ %{}) do
    vehicle.movement_model.next_state(vehicle, sections, signals_by_location)
  end

end

