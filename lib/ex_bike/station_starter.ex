defmodule ExBike.StationStarter do
  use GenServer
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
    IO.puts("Creating all the stuff!!")
    Logger.info("[Station Starter] Creating stations.")
  end
end
