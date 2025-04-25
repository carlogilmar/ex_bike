defmodule ExBikeWeb.DashboardLive do
  use ExBikeWeb, :live_view
  alias ExBike.Station

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ExBike.PubSub, "stations")

    {:ok, assign(socket, stations: fetch_all_stations(), station_id: nil, show_updates: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">🚲 Station Dashboard</h1>
      <form phx-submit="simulate-update" class="mb-4 flex items-center gap-4">
        <input
          type="text"
          name="station_id"
          placeholder="Enter station ID"
          value={@station_id || ""}
          class="border rounded px-3 py-1 text-sm"
        />

        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded shadow">
          🔁 Simulate Update
        </button>
      </form>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <%= for station <- @stations do %>
          <.live_component
            module={ExBikeWeb.StationComponent}
            id={"station-#{station.id}"}
            station={station}
            highlight={false}
          />
        <% end %>
      </div>
    </div>

    <%= if @show_updates do %>
      <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white rounded-xl shadow-lg w-full max-w-md p-6 relative">
          <button
            phx-click="close-updates"
            class="absolute top-3 right-4 text-gray-400 hover:text-black text-xl"
          >
            &times;
          </button>

          <h2 class="text-xl font-bold mb-4">
            Updates for Station {@selected_station_id}
          </h2>

          <ul class="space-y-2 max-h-80 overflow-y-auto text-sm">
            <%= for u <- @updates do %>
              <li class="border-b pb-1">
                🕒 {u.updated_at} –
                🚲 {u.previous_bikes_availables} → {u.current_bikes_availables}
              </li>
            <% end %>
          </ul>

          <div class="mt-4 text-right">
            <button phx-click="close-updates" class="text-blue-600 hover:underline">
              Close
            </button>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  @impl true
  def handle_info({:station_updated, updated_station}, socket) do
    send_update(ExBikeWeb.StationComponent,
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
    send_update(ExBikeWeb.StationComponent,
      id: "station-#{station.id}",
      station: station,
      highlight: false
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("show-updates", %{"id" => station_id}, socket) do
    station = Station.get_station(station_id)

    {:noreply,
     assign(socket,
       show_updates: true,
       updates: station.bike_updates,
       selected_station_id: station_id
     )}
  end

  @impl true
  def handle_event("close-updates", _params, socket) do
    {:noreply, assign(socket, show_updates: false, updates: [], selected_station_id: nil)}
  end

  @impl true
  def handle_event("simulate-update", %{"station_id" => station_id}, socket) do
    stations = socket.assigns.stations

    random_station = Enum.find(stations, fn station -> station.id == station_id end)

    updated_station = %{random_station | bikes_available: Enum.random(1..1000)}

    send_update(ExBikeWeb.StationComponent,
      id: "station-#{updated_station.id}",
      station: updated_station,
      highlight: true
    )

    Process.send_after(self(), {:clear_highlight, updated_station}, 3000)

    # Optionally clear the input field by setting it to nil or an empty string
    socket =
      socket
      |> assign(:station_id, "")

    {:noreply, socket}
  end

  defp fetch_all_stations do
    Registry.select(StationRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.shuffle()
    |> Enum.map(&Station.get_station/1)
  end
end
