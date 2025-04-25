defmodule ExBikeWeb.DashboardLive do
  use ExBikeWeb, :live_view
  alias ExBike.Station

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :stations, fetch_all_stations())}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">🚲 Station Dashboard</h1>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <%= for station <- @stations do %>
          <div class="bg-white shadow-md rounded-xl p-4 border border-gray-200">
            <h2 class="text-lg font-semibold"><%= station.name %></h2>
            <span class="text-xs text-gray-400">ID: <%= station.id %></span>
            <p class="text-sm text-gray-600">Lat: <%= Float.round(station.lat, 4) %></p>
            <p class="text-sm text-gray-600">Lon: <%= Float.round(station.lon, 4) %></p>
            <p class="mt-2 text-sm font-medium text-green-600">
              Bikes: <%= station.bikes_available || 0 %>
            </p>
            <p class="mt-2 text-sm font-medium text-green-600">
              🚴 Bikes: <%= station.bikes_available || 0 %>
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp fetch_all_stations do
    Registry.select(StationRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.map(&Station.get_station/1)
  end
end

