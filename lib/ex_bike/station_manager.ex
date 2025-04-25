defmodule ExBike.StationManager do
  alias ExBike.Station
  alias ExBike.StationSupervisor

  def start_station(attrs) do
    spec = %{
      id: Station,
      start: {Station, :start_link, [attrs]},
      restart: :transient,
      type: :worker
    }

    DynamicSupervisor.start_child(StationSupervisor, spec)
  end
end
