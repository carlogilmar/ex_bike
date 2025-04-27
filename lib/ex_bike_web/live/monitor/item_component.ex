defmodule ExBikeWeb.MonitorLive.ItemComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div
      id={"station-#{@station.id}"}
      phx-click="station_clicked"
      phx-value-id={@station.id}
      class={[
        "flex items-center justify-center rounded-md text-white text-xs font-bold cursor-pointer",
        @highlight && "bg-amber-500 animate-pulse",
        !@highlight && "bg-slate-800"
      ]}
    >
      {@station.bikes_available}
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
