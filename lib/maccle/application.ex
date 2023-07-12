defmodule Maccle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MaccleWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Maccle.PubSub},
      # Start Finch
      {Finch, name: Maccle.Finch},
      # Start the Endpoint (http/https)
      MaccleWeb.Endpoint,
      # Start a worker by calling: Maccle.Worker.start_link(arg)
      # {Maccle.Worker, arg}

      {Maccle.MessageEncoder.Server, name: Maccle.MessageEncoder.Server}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Maccle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MaccleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
