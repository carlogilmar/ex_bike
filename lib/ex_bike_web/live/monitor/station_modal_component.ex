defmodule ExBikeWeb.MonitorLive.StationModalComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg w-80">
        <h2 class="text-xl font-bold mb-4">Station Details</h2>
        <div class="space-y-2">
          <div><strong>Name:</strong> {@station.name || "Station Name"}</div>
          <div><strong>Bikes Available:</strong> {@station.bikes_available || 0}</div>
          <div><strong>Latitude:</strong> {@station.lat || 0.0}</div>
          <div><strong>Longitude:</strong> {@station.lon || 0.0}</div>
        </div>
        <button
          class="mt-6 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          phx-click="close_modal"
        >
          Close
        </button>
      </div>
    </div>
    """
  end
end
