defmodule ExBikeWeb.MonitorLive.Index do
  use ExBikeWeb, :live_view
  alias ExBike.Station

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ExBike.PubSub, "monitor")

    {:ok,
     assign(socket,
       stations: fetch_all_stations(),
       selected_station: nil
     )}
  end

  @impl true
  def handle_event("station_clicked", %{"id" => station_id}, socket) do
    station = Station.get_station(station_id)
    {:noreply, assign(socket, selected_station: station)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :selected_station, nil)}
  end

  @impl true
  def handle_info({:station_updated, updated_station}, socket) do
    send_update(ExBikeWeb.MonitorLive.ItemComponent,
      id: "station-#{updated_station.id}",
      station: updated_station,
      highlight: true
    )

    # Optional: remove highlight after a second
    Process.send_after(self(), {:clear_highlight, updated_station}, 4000)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:clear_highlight, station}, socket) do
    send_update(ExBikeWeb.MonitorLive.ItemComponent,
      id: "station-#{station.id}",
      station: station,
      highlight: false
    )

    {:noreply, socket}
  end

  defp fetch_all_stations do
    Registry.select(StationRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.shuffle()
    |> Enum.map(&Station.get_station/1)
  end
end
