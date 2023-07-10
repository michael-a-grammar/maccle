defmodule MaccleCode.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {MaccleCode.Server, eager_load_words_for_common_letters()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp eager_load_words_for_common_letters() do
    value = Application.fetch_env!(:maccle_code, :eager_load_words_for_common_letters)
    IO.inspect(value, label: "Eager?")
    value
  end
end
