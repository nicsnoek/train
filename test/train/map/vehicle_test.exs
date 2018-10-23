defmodule Train.Map.VehicleTest do
  use Train.DataCase

  alias Train.Map.DefaultMovementModel
  alias Train.Map.Section
  alias Train.Map.Vehicle
  alias Train.Map.Signal

  @sectionA Section.new("A", "B")
  @sectionB Section.new("B", "C")
  @sectionC Section.new("C", "A", "B")

  describe "as_tile" do
    test "returns map with all vehicle parameters" do
      vehicle = %{Vehicle.new("A", DefaultMovementModel)|distance_to_next_section: 1, max_acceleration: 2, max_speed: 3, speed: 4 }
      vehicle_as_tile = Vehicle.as_tile(vehicle)
      assert(vehicle_as_tile == %{
        location: "A",
        distance_to_next_section: 1,
        max_acceleration: 2,
        max_speed: 3,
        speed: 4
      })
    end
  end

  describe "with DefaultMovementModel, next_state" do

    test "accelerates vehicle from standstill" do
      sections = [@sectionA, @sectionB]
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 0, max_acceleration: 15}
      next_vehicle = Vehicle.next_state(vehicle, sections)
      assert(next_vehicle.speed == 15)
    end

    test "moves closer to next section based on INITIAL speed" do
      sections = [@sectionA, @sectionB]
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 0, max_acceleration: 10, distance_to_next_section: 100}
      next_vehicle = Vehicle.next_state(vehicle, sections)
      assert(next_vehicle.speed == 10)
      assert(next_vehicle.distance_to_next_section == 100)
      next_vehicle = Vehicle.next_state(next_vehicle, sections)
      assert(next_vehicle.speed == 20)
      assert(next_vehicle.distance_to_next_section == 90)
    end

    test "does not accelerate beyond max_speed" do
      sections = [@sectionA, @sectionB]
      vehicle = Vehicle.new("A", DefaultMovementModel)
      vehicle_near_max_speed = %{vehicle|speed: vehicle.max_speed - 1 }
      next_vehicle = Vehicle.next_state(vehicle_near_max_speed, sections)
      assert(next_vehicle.speed == vehicle.max_speed)
    end

    test "moves into next section" do
      sections = [@sectionA, %{@sectionB|distance: 100}]
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 10, max_speed: 10, distance_to_next_section: 8}
      next_vehicle = Vehicle.next_state(vehicle, sections)
      assert(next_vehicle.location == "B")
      assert(next_vehicle.distance_to_next_section == 98)
    end

    test "decelerates so that vehicle stops at next signal at stop, moving closer to next section based on INITIAL speed" do
      ## remaining distance = 15, speed = 5,4,3,2,1
      sections = [@sectionA, @sectionB]
      signal_b_at_stop = %{"B" => Signal.at_stop("B")}
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 5, distance_to_next_section: 15 }
      next_vehicle = Vehicle.next_state(vehicle, sections, signal_b_at_stop)

      assert(next_vehicle.speed == 4)
      assert(next_vehicle.distance_to_next_section == 10)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 3)
      assert(next_vehicle.distance_to_next_section == 6)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 2)
      assert(next_vehicle.distance_to_next_section == 3)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 1)
      assert(next_vehicle.distance_to_next_section == 1)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 0)
      assert(next_vehicle.distance_to_next_section == 0)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 0)
      assert(next_vehicle.distance_to_next_section == 0)
    end

    test "decelerates HARD so that vehicle stops at next signal at stop" do
      sections = [@sectionA, @sectionB, @sectionC]
      signal_b_at_stop = %{"B" => Signal.at_stop("B")}
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 80, distance_to_next_section: 100 }
      next_vehicle = Vehicle.next_state(vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 27)
      assert(next_vehicle.distance_to_next_section == 20)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
      assert(next_vehicle.speed == 0)
      assert(next_vehicle.distance_to_next_section == 0)
#      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_stop)
    end

    test "decelerates to turnout_speed_limit when next signal at turnout, moving closer to next section based on INITIAL speed" do
      sections = [@sectionA, %{@sectionB|turnout_speed_limit: 10}]
      signal_b_at_turnout = %{"B" => Signal.at_turnout("B")}
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 15, distance_to_next_section: 75 }
      next_vehicle = Vehicle.next_state(vehicle, sections, signal_b_at_turnout)

#      15,14,13,12,11,10 =75

      assert(next_vehicle.speed == 14)
      assert(next_vehicle.distance_to_next_section == 60)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 13)
      assert(next_vehicle.distance_to_next_section == 46)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 12)
      assert(next_vehicle.distance_to_next_section == 33)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 11)
      assert(next_vehicle.distance_to_next_section == 21)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 10)
      assert(next_vehicle.distance_to_next_section == 10)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 10)
      assert(next_vehicle.distance_to_next_section == 0)
    end

    test "does not accelerate beyond max_turnout_speed when next signal at turnout, moving closer to next section based on INITIAL speed" do
      sections = [%{@sectionA|turnout_speed_limit: 4}, @sectionB]
      signal_b_at_turnout = %{"B" => Signal.at_turnout("B")}
      vehicle = %{Vehicle.new("A", DefaultMovementModel)| speed: 0, max_acceleration: 2, distance_to_next_section: 10 }
      next_vehicle = Vehicle.next_state(vehicle, sections, signal_b_at_turnout)

      assert(next_vehicle.speed == 2)
      assert(next_vehicle.distance_to_next_section == 10)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 4)
      assert(next_vehicle.distance_to_next_section == 8)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 4)
      assert(next_vehicle.distance_to_next_section == 4)
      next_vehicle = Vehicle.next_state(next_vehicle, sections, signal_b_at_turnout)
      assert(next_vehicle.speed == 4)
      assert(next_vehicle.distance_to_next_section == 0)
    end
  end
end

