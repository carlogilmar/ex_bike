defmodule ExBike.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExBikeWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ex_bike, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExBike.PubSub},
      # Start a worker by calling: ExBike.Worker.start_link(arg)
      # {ExBike.Worker, arg},
      # Start to serve requests, typically the last entry
      {Registry, keys: :unique, name: StationRegistry},
      {Registry, keys: :unique, name: StationHistoryRegistry},
      {ExBike.StationSupervisor, []},
      ExBike.StationStarter,
      ExBike.StationSync,
      ExBikeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBike.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExBikeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
