defprotocol AndThen do
  @moduledoc false
  def next_state(state)
end
