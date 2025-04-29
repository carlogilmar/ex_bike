defmodule ExBike.StationHistory do
  use GenServer

  defstruct [:station_id, :arrivals, :departures]

  def start_link(%{id: id, year: year, month: month} = attrs) do
    station_history_process_id = "station-history-#{id}-#{year}-#{month}" |> IO.inspect()

    GenServer.start_link(__MODULE__, attrs,
      name: {:via, Registry, {StationHistoryRegistry, station_history_process_id}}
    )
  end

  def add_arrival(station_history_id, arrival) do
    GenServer.cast(
      {:via, Registry, {StationHistoryRegistry, station_history_id}},
      {:add_arrival, arrival}
    )
  end

  def add_departure(station_history_id, departure) do
    GenServer.cast(
      {:via, Registry, {StationHistoryRegistry, station_history_id}},
      {:add_departure, departure}
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
  def handle_cast({:add_arrival, arrival}, %__MODULE__{arrivals: arrivals} = history_station) do
    arrivals_updated = [arrival | arrivals]
    history_station_updated = %{history_station | arrivals: arrivals_updated}
    {:noreply, history_station_updated}
  end

  @impl true
  def handle_cast(
        {:add_departure, departure},
        %__MODULE__{departures: departures} = history_station
      ) do
    departures_updated = [departure | departures]
    history_station_updated = %{history_station | departures: departures_updated}
    {:noreply, history_station_updated}
  end

  defp create_station_history(attrs) do
    %__MODULE__{
      station_id: attrs.id,
      departures: [],
      arrivals: []
    }
  end
end
