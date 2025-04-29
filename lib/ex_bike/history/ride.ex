defmodule ExBike.Ride do
  use GenServer

  defstruct [
    :bike_id,
    :user_genre,
    :user_age,
    :station_departure,
    :departure_date,
    :departure_hour,
    :station_arrival,
    :arrival_date,
    :arrival_hour
  ]

  def start_link(row_attrs) do
    ride = match_ride_from_row(row_attrs)

    ride_id = "ride-#{ride.bike_id}-#{ride.departure_date}-#{ride.departure_hour}"

    GenServer.start_link(__MODULE__, ride, name: {:via, Registry, {RidesRegistry, ride_id}})
  end

  def get_movement(ride_id) do
    GenServer.call({:via, Registry, {RidesRegistry, ride_id}}, :get_movement)
  end

  @impl true
  def init(ride) do
    {:ok, ride}
  end

  @impl true
  def handle_call(:get_movement, _from, ride) do
    {:reply, ride, ride}
  end

  defp match_ride_from_row([
         genre,
         age,
         bike_id,
         start_station,
         start_date,
         start_time,
         end_station,
         end_date,
         end_time
       ]) do
    %__MODULE__{
      bike_id: bike_id,
      departure_date: start_date,
      departure_hour: start_time,
      station_departure: start_station,
      user_genre: genre,
      user_age: age,
      arrival_date: end_date,
      arrival_hour: String.trim(end_time),
      station_arrival: end_station
    }
  end
end
