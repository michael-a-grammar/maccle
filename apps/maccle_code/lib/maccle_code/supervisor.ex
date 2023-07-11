defmodule MaccleCode.Supervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    children = [
      {MaccleCode.Server, name: MaccleCode.Server}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
