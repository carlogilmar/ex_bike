defmodule ExBike.CSVReader do
  @doc """
  Reads a CSV file and returns a list of maps for each row (excluding headers).
  """
  def read_csv(path) do
    path
    |> File.stream!()
    # skip the headers
    |> Stream.drop(1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(&spawn_processes/1)
  end

  defp spawn_processes(row) do
    [_, _, bike_id, station_id, departure_date, departure_hour, _, _, _] = row
    ride_id = "ride-#{bike_id}-#{departure_date}-#{departure_hour}" |> IO.inspect()
    station_history_id = "station-day-history-#{station_id}-#{departure_date}" |> IO.inspect()
    ExBike.RideSupervisor.start_ride(row)
  end
end
