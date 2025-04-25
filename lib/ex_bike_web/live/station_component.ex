defmodule ExBikeWeb.StationComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div
      id={"station-#{@station.id}"}
      class={[
        "shadow-md rounded-xl p-4 border border-gray-200 transition-all duration-500 ease-in-out",
        @highlight && "bg-yellow-100 animate-pulse",
        !@highlight && "bg-white"
      ]}
    >
      <h2 class="text-lg font-semibold">{@station.name}</h2>
      <span class="text-xs text-gray-400">ID: {@station.id}</span>
      <p class="text-sm text-gray-600">Lat: {Float.round(@station.lat, 4)}</p>
      <p class="text-sm text-gray-600">Lon: {Float.round(@station.lon, 4)}</p>
      <p class="mt-2 text-sm font-medium text-green-600">
        🚴 Bikes: {@station.bikes_available || 0}
      </p>
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:station, assigns.station)
      |> assign(:highlight, Map.get(assigns, :highlight, false))

    {:ok, socket}
  end
end
