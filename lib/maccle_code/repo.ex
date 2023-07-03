defmodule MaccleCode.Repo do
  use Ecto.Repo,
    otp_app: :maccle_code,
    adapter: Ecto.Adapters.Postgres
end
