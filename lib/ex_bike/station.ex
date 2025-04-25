defmodule ExBike.Station do
  use GenServer
  require Logger
  @max_updates 1000

  defstruct [
    :id,
    :external_id,
    :capacity,
    :lat,
    :lon,
    :name,
    :rental_methods,
    :short_name,
    :bikes_available,
    :bikes_disable,
    :docks_available,
    :docks_disabled,
    :bike_updates
  ]

  def start_link(attrs) do
    station = match_struct(attrs)

    GenServer.start_link(__MODULE__, station,
      name: {:via, Registry, {StationRegistry, station.id}}
    )
  end

  def get_station(station_id) do
    GenServer.call({:via, Registry, {StationRegistry, station_id}}, :get_station)
  end

  def update_status(station_id, updates) do
    GenServer.cast({:via, Registry, {StationRegistry, station_id}}, {:update_status, updates})
  end

  @impl true
  def init(station) do
    {:ok, station}
  end

  @impl true
  def handle_call(:get_station, _from, station) do
    {:reply, station, station}
  end

  @impl true
  def handle_cast({:update_status, attrs}, station) do
    updated_station =
      if station.bikes_available != attrs["num_bikes_available"] do
        Logger.info(
          "[Station Sync][#{station.id}] Station #{station.name} moved from #{station.bikes_available} to #{attrs["num_bikes_available"]} bikes availables"
        )

        # Saving the update
        new_update = %{
          updated_at: NaiveDateTime.utc_now(),
          previous_bikes_availables: station.bikes_available,
          current_bikes_availables: attrs["num_bikes_available"]
        }

        bike_updates = [new_update | station.bike_updates] |> Enum.take(@max_updates)

        updated_station =
          Map.merge(station, %{
            bikes_available: attrs["num_bikes_available"],
            bikes_disable: attrs["num_bikes_disabled"],
            docks_available: attrs["num_docks_available"],
            docks_disabled: attrs["num_docks_disabled"],
            bike_updates: bike_updates
          })

        Phoenix.PubSub.broadcast(
          ExBike.PubSub,
          "stations",
          {:station_updated, updated_station}
        )

        updated_station
      else
        station
      end

    {:noreply, updated_station}
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
      short_name: station_attrs["short_name"],
      bikes_available: 0,
      bike_updates: []
    }
  end
end
