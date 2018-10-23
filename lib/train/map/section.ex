defmodule Train.Map.Section do
  @moduledoc false

  defstruct from: nil, to: nil, turnout_to: nil, distance: 100, speed_limit: 100, turnout_speed_limit: 10

  def new(from, to, turnout_to) do
    %__MODULE__{
      from: from,
      to: to,
      turnout_to: turnout_to,
    }
  end

  def new(from, to) do
    new(from, to, nil)
  end

end
