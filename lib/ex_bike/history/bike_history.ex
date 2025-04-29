defmodule ExBike.BikeHistory do
  use GenServer

  defstruct [:bike_id, :arrivals, :departures]

  def start_link(%{id: id, year: year, month: month} = attrs) do
    bike_history_process_id = "bike-history-#{id}-#{year}-#{month}" |> IO.inspect()

    GenServer.start_link(__MODULE__, attrs,
      name: {:via, Registry, {BikeHistoryRegistry, bike_history_process_id}}
    )
  end

  def add_arrival(bike_history_id, arrival) do
    GenServer.cast(
      {:via, Registry, {BikeHistoryRegistry, bike_history_id}},
      {:add_arrival, arrival}
    )
  end

  def add_departure(bike_history_id, departure) do
    GenServer.cast(
      {:via, Registry, {BikeHistoryRegistry, bike_history_id}},
      {:add_departure, departure}
    )
  end

  def get_history(bike_history_id) do
    GenServer.call({:via, Registry, {BikeHistoryRegistry, bike_history_id}}, :get_history)
  end

  @impl true
  def init(attrs) do
    bike_history = create_bike_history(attrs)
    {:ok, bike_history}
  end

  @impl true
  def handle_call(:get_history, _from, bike_history) do
    {:reply, bike_history, bike_history}
  end

  @impl true
  def handle_cast({:add_arrival, arrival}, %__MODULE__{arrivals: arrivals} = bike_history) do
    arrivals_updated = [arrival | arrivals]
    bike_history_updated = %{bike_history | arrivals: arrivals_updated}
    {:noreply, bike_history_updated}
  end

  @impl true
  def handle_cast(
        {:add_departure, departure},
        %__MODULE__{departures: departures} = bike_history
      ) do
    departures_updated = [departure | departures]
    bike_history_updated = %{bike_history | departures: departures_updated}
    {:noreply, bike_history_updated}
  end

  defp create_bike_history(attrs) do
    %__MODULE__{
      bike_id: attrs.id,
      departures: [],
      arrivals: []
    }
  end
end
