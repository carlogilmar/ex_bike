defmodule ExBike.StationsActivity do
  alias ExBike.Station

  def most_active_stations(seconds_ago \\ 3600) do
    StationRegistry
    |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.map(fn station_id ->
      case Registry.lookup(StationRegistry, station_id) do
        [{pid, _}] ->
          count = Station.get_recent_update_count(pid, seconds_ago)
          station = Station.get_station(station_id)
          {station_id, station.name, count}

        _ ->
          {station_id, "", 0}
      end
    end)
    |> Enum.sort_by(fn {_id, _name, count} -> -count end)
    # Limit to the top 10 active stations
    |> Enum.take(10)
  end
end
