defmodule MovementModel do
  @callback next_state(Vehicle.t, [Section.t], %{optional(String.t()) => Train.Map.Signal.t}) :: Vehicle.t
end
