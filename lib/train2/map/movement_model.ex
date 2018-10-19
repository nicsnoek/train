defmodule MovementModel do
  @callback next_state(Vehicle.t, [Section.t], %{optional(String.t()) => Train2.Map.Signal.t}) :: Vehicle.t
end
