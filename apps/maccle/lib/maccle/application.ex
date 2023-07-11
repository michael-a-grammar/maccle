defmodule Maccle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Maccle.PubSub},
      # Start Finch
      {Finch, name: Maccle.Finch}
      # Start a worker by calling: Maccle.Worker.start_link(arg)
      # {Maccle.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Maccle.Supervisor)
  end
end
