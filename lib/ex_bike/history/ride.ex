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

  def start_link(attrs) do
    ride = match_ride(attrs)

    ride_id = "ride-#{ride.bike_id}-#{ride.departure_date}-#{ride.departure_hour}" |> IO.inspect()

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

  defp match_ride(attrs) do
    %__MODULE__{
      bike_id: attrs.bike_id,
      departure_date: attrs.departure_date,
      departure_hour: attrs.departure_hour
    }
  end
end
