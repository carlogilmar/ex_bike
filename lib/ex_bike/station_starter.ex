defmodule ExBike.StationStarter do
  use GenServer
  alias ExBike.StationAPI
  alias ExBike.StationManager
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    initialize_stations()
    {:ok, %{}}
  end

  defp initialize_stations do
    stations = StationAPI.get_stations()

    Enum.each(stations, fn %{"station_id" => station_id} = station ->
      {:ok, _pid} = StationManager.start_station(station)
      Logger.info("[Station Starter] Station with ID #{station_id} initialized.")
    end)
  end
end
