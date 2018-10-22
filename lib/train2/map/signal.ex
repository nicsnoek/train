defmodule Train2.Map.Signal do
  @moduledoc false

  @stop :stop
  @turnout :turnout
  @clear :clear

  defstruct location: nil, has_turnout: false, state: @stop

  def new(location, state) do
    %__MODULE__{
      location: location,
      state: state,
    }
  end

  def with_turnout(signal) do
    %{signal|has_turnout: true}
  end

  defp by_location(list) do
    Enum.reduce(list, %{}, fn (item, acc) -> Map.put(acc, item.location, item) end)
  end

  def state(signal_by_location, location) do
    signal = signal_by_location[location]
    (signal && signal.state) || @clear
  end

  def signals(signals) do
    by_location(signals)
  end

  def at(signals, location) do
    Map.get(signals, location)
  end

  def at_stop(location) do
    new(location, @stop)
  end

  def at_turnout(location) do
    new(location, @turnout)
  end

  def is_stop(signal) do
    signal.state == @stop
  end

  def stop() do
    @stop
  end

  def clear() do
    @clear
  end

  def turnout() do
    @turnout
  end

  def cancel_at(signals, location) do
    signal = signals |> at(location)
    if signal == nil || is_stop(signal) do
      signals
    else
      Map.put(signals, signal.location, at_stop(signal.location))
    end
  end

  def set_occupied_locations_to_stop(signals, occupied_locations) do
    Enum.reduce(
      occupied_locations,
      signals,
      fn location, acc -> cancel_at(acc, location) end
    )
  end

  defp toggle_state(state) do
    if state == @stop do
      @clear
    else
      @stop
    end
  end

  def toggle_signal(signals, location) do
    signal = signals |> at(location)
    if signal == nil do
      signals
    else
      Map.put(signals, signal.location, %{signal|state: toggle_state(signal.state)})
    end
  end

end
