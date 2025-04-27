defmodule ExBikeWeb.MonitorLive.ItemComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div
      id={"station-#{@station.id}"}
      class="flex items-center justify-center bg-slate-400 rounded-md text-white text-xs font-bold"
    >
      {@station.bikes_available}
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:station, assigns.station)

    {:ok, socket}
  end
end
