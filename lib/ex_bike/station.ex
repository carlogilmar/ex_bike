defmodule ExBike.Station do
  use GenServer

  defstruct [:id, :external_id, :capacity, :lat, :lon, :name, :rental_methods, :short_name]

  def start_link(attrs) do
    station = match_struct(attrs)

    GenServer.start_link(__MODULE__, station,
      name: {:via, Registry, {StationRegistry, station.id}}
    )
  end

  def get_station(station_id) do
    GenServer.call({:via, Registry, {StationRegistry, station_id}}, :get_station)
  end

  @impl true
  def init(station) do
    {:ok, station}
  end

  @impl true
  def handle_call(:get_station, _from, station) do
    {:reply, station, station}
  end

  defp match_struct(station_attrs) do
    %__MODULE__{
      id: station_attrs["station_id"],
      external_id: station_attrs["external_id"],
      capacity: station_attrs["capacity"],
      lat: station_attrs["lat"],
      lon: station_attrs["lon"],
      name: station_attrs["name"],
      rental_methods: station_attrs["rental_methods"],
      short_name: station_attrs["short_name"]
    }
  end
end
