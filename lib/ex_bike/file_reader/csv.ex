defmodule ExBike.CSVReader do
  @doc """
  Reads a CSV file and returns a list of maps for each row (excluding headers).
  """
  def read_csv(path) do
    path
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(&spawn_processes/1)
  end

  defp spawn_processes(row) do
    [_, _, bike_id, station_id, departure_date, departure_hour, _, _, _] = row
    ride_id = "ride-#{bike_id}-#{departure_date}-#{departure_hour}"
    station_history_id = "station-day-history-#{station_id}-#{departure_date}"
    station_day_history_attrs = %{id: station_id, date: departure_date}
    ExBike.RideSupervisor.start_ride(row)
    add_ride_to_station_day_history(station_history_id, station_day_history_attrs, ride_id)
  end

  def add_ride_to_station_day_history(station_history_day_id, attrs, ride_id) do
    case Registry.lookup(StationHistoryRegistry, station_history_day_id) do
      [{pid, _}] ->
        ExBike.StationDayHistory.add_ride(station_history_day_id, ride_id)
        {:ok, pid}

      [] ->
        case ExBike.StationDayHistorySupervisor.start_station_day_history(attrs) do
          {:ok, pid} ->
            ExBike.StationDayHistory.add_ride(station_history_day_id, ride_id)
						{:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
          error -> error
        end
    end
  end
end
