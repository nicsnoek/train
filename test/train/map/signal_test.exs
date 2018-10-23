defmodule Train.Map.SignalTest do
  use Train.DataCase

  alias Train.Map.Signal

  describe "as_tile" do
    test "returns map with parameters at stop" do
      tile = Signal.as_tile(Signal.at_stop("A"))
      assert(tile == %{
        state: :stop,
        has_turnout: false
      })
    end

    test "returns map with parameters at turnout" do
      tile = Signal.as_tile(Signal.at_turnout("A") |> Signal.with_turnout)
      assert(tile == %{
        state: :turnout,
        has_turnout: true
      })
    end
  end
end

