defmodule ExBike.StationSync do
  use GenServer
  alias ExBike.Station
  alias ExBike.StationAPI
  require Logger

  @sync_interval :timer.minutes(1)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def sync_now do
    GenServer.cast(__MODULE__, :sync_now)
  end

  @impl true
  def init(:ok) do
    :timer.send_interval(@sync_interval, :sync_stations)
    {:ok, %{}}
  end

  @impl true
  def handle_cast(:sync_now, state) do
    update_stations_status()
    {:noreply, state}
  end

  @impl true
  def handle_info(:sync_stations, state) do
    update_stations_status()
    {:noreply, state}
  end

  def update_stations_status do
    stations_updates = StationAPI.get_stations_updates()

    stations_updates
    |> Task.async_stream(
      fn %{"station_id" => station_id} = station_update ->
        Station.update_status(station_id, station_update)
        Logger.info("[Station Sync] Station with ID #{station_id} updated")
      end,
      max_concurrency: 10,
      timeout: 5_000
    )
    |> Stream.run()
  end
end
