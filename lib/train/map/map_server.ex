defmodule Train.Map.MapServer do
  use GenServer

  alias Train.Map.Map

  # Client API

  @name __MODULE__

  def start_link(initial_state) do
     GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def read() do
    GenServer.call(@name, {:read})
  end

  def tick() do
    GenServer.cast(@name, {:tick})
  end

  def toggle_signal(location) do
    GenServer.cast(@name, {:toggle_signal, location: location})
  end

  def reset() do
    GenServer.cast(@name, {:reset})
  end

  # Server Callbacks

  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_call({:read}, _from, map) do
    tiles = Map.as_tiles(map)
    {:reply, tiles, map}
  end

  def handle_cast({:tick}, map) do
    next_state = Map.next_state(map)
    {:noreply, next_state}
  end

  def handle_cast({:reset}, map) do
    next_state = Map.reset(map)
    {:noreply, next_state}
  end

  def handle_cast({:toggle_signal, location: location}, map) do
    IO.puts "Location toggled #{location}"
    next_state = Map.toggle_signal(map, location)
    {:noreply, next_state}
  end

end