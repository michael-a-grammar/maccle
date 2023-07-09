defmodule MaccleCode.Messaging do
  use Application

  def start(_type, _args) do
    children = [
      {MaccleCode.Messaging.Supervisor, name: MaccleCode.Messaging.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
