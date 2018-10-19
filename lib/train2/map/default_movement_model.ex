defmodule Train2.Map.DefaultMovementModel do
  @moduledoc false
  @behaviour MovementModel

  alias Train2.Map.Signal

  @signal_clear Signal.clear()
  @signal_stop Signal.stop()
  @signal_turnout Signal.turnout()

  defp deceleration_required(initial_speed, final_speed, distance) do
    if (final_speed == initial_speed) do
      0 # by definition
    else
      divisor = (2 * distance - initial_speed - final_speed)
      if (divisor != 0) do
        round((initial_speed * initial_speed - final_speed * final_speed) / divisor)
      else
        difference = initial_speed - final_speed
        IO.puts("Beware the singularity, wash off #{difference} with #{distance} left to run")
        difference
      end
    end
  end

  defp decelerate_to(vehicle, decelerate_to_speed, next_section) do
    deceleration = deceleration_required(vehicle.speed, decelerate_to_speed, vehicle.distance_to_next_section)
    new_speed = max(vehicle.speed - deceleration, 0)
    moved_vehicle(vehicle, new_speed, next_section)
  end

  defp accelerate_to(vehicle, accelerate_to_speed, next_section) do
    new_speed = min(vehicle.speed + vehicle.max_acceleration, accelerate_to_speed)
    moved_vehicle(vehicle, new_speed, next_section)
  end

  defp moved_vehicle(vehicle, new_speed, next_section) do
    new_distance_to_next_section = vehicle.distance_to_next_section - vehicle.speed
    if (new_distance_to_next_section >= 0) do
      %{vehicle| speed: new_speed, distance_to_next_section: new_distance_to_next_section}
    else
    if next_section == nil do
      IO.puts("About to overrun section by #{-new_distance_to_next_section}, hit trainstop!")
      %{vehicle| speed: 0, distance_to_next_section: 0}
    else
      %{vehicle| location: next_section.from, speed: new_speed, distance_to_next_section: next_section.distance + new_distance_to_next_section}
    end
    end
  end

  defp get_section(sections, location) do
    Enum.find(sections, fn section -> section.from == location end)
  end

  def next_state(vehicle, sections, signals_by_location) do
    section_with_vehicle = get_section(sections, vehicle.location)
    case Signal.state(signals_by_location, section_with_vehicle.to) do
      @signal_clear ->
        next_section = get_section(sections, section_with_vehicle.to)
        accelerate_to(vehicle, vehicle.max_speed, next_section)
      @signal_turnout ->
        next_section = get_section(sections, section_with_vehicle.turnout_to)
        if vehicle.speed >= section_with_vehicle.turnout_speed_limit do
#        IO.puts("decelerate_to(vehicle, #{section_with_vehicle.turnout_speed_limit})")
          decelerate_to(vehicle, section_with_vehicle.turnout_speed_limit, next_section)
        else
#        IO.puts("accelerate_to(vehicle, #{section_with_vehicle.turnout_speed_limit})")
          accelerate_to(vehicle, section_with_vehicle.turnout_speed_limit, next_section)
        end
      @signal_stop ->
        decelerate_to(vehicle, 0, nil)
    end
  end
end
