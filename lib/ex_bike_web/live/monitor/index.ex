defmodule ExBikeWeb.MonitorLive.Index do
  use ExBikeWeb, :live_view
  alias ExBike.Station

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       stations: fetch_all_stations()
     )}
  end

  defp fetch_all_stations do
    Registry.select(StationRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.shuffle()
    |> Enum.map(&Station.get_station/1)
  end
end
