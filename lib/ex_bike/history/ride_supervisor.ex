defmodule ExBike.RideSupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_ride(attrs) do
    child_spec = %{
      id: ExBike.Ride,
      start: {ExBike.Ride, :start_link, [attrs]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def get_all_rides do
    Registry.select(RidesRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end
end
