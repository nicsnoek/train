defmodule Train2Test.AlwaysAdvance do
  @behaviour MovementModel
  def next_state(vehicle, sections, _signals) do
    section_with_vehicle = Enum.find(sections, fn section -> section.from == vehicle.location end)
    %{vehicle | location: section_with_vehicle.to}
  end
end

