defmodule Train2.Map.Signal do
  @moduledoc false

  @stop :stop
  @turnout :turnout
  @clear :clear

  defstruct location: nil, state: @stop

  def new(location, state) do
    %__MODULE__{
      location: location,
      state: state
    }
  end

  def state(signal_by_location, location) do
    signal = signal_by_location[location]
    (signal && signal.state) || @clear
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

end
