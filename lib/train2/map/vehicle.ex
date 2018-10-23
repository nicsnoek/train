defmodule Train2.Map.Vehicle do
  @moduledoc false

  alias Train2.Map.Signal

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

  def next_state(vehicle, sections, signals \\ Signal.signals([])) do
    vehicle.movement_model.next_state(vehicle, sections, signals)
  end

  def as_tile(vehicle) do
    Map.from_struct(vehicle) |> Map.delete(:movement_model)
  end

end

