defmodule ExBike.StationDayHistory do
  use GenServer

  defstruct [:station_id, :rides, :date]

  def start_link(%{id: id, date: date} = attrs) do
    station_history_id = "station-day-history-#{id}-#{date}"

    GenServer.start_link(__MODULE__, attrs,
      name: {:via, Registry, {StationHistoryRegistry, station_history_id}}
    )
  end

  def add_ride(station_history_id, ride) do
    GenServer.cast(
      {:via, Registry, {StationHistoryRegistry, station_history_id}},
      {:add_ride, ride}
    )
  end

  def get_history(station_history_id) do
    GenServer.call({:via, Registry, {StationHistoryRegistry, station_history_id}}, :get_history)
  end

  @impl true
  def init(attrs) do
    station_history = create_station_history(attrs)
    {:ok, station_history}
  end

  @impl true
  def handle_call(:get_history, _from, history_station) do
    {:reply, history_station, history_station}
  end

  @impl true
  def handle_cast({:add_ride, ride}, %__MODULE__{rides: rides} = history_station) do
    rides_updated = [ride | rides]
    history_station_updated = %{history_station | rides: rides_updated}
    {:noreply, history_station_updated}
  end

  defp create_station_history(attrs) do
    %__MODULE__{
      station_id: attrs.id,
      date: attrs.date,
      rides: []
    }
  end
end
