defmodule ExBikeWeb.RidesLive.Index do
  use ExBikeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ExBike.PubSub, "rides_processed")
    socket = socket |> assign(:loading, false) |> assign(:ride_processed, "")
    {:ok, stream(socket, :rides, [])}
  end

  @impl true
  def handle_info({:new_ride, ride}, socket) do
    socket = socket |> assign(:loading, true) |> assign(:ride_processed, ride.id)
    Process.send_after(self(), :clear_highlight, 3000)
    {:noreply, stream_insert(socket, :rides, ride, at: -1)}
  end

  def handle_info(:clear_highlight, socket) do
    socket = socket |> assign(:loading, false)
    {:noreply, socket}
  end
end
