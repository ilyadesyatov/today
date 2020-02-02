defmodule Today.Repo do
  use Ecto.Repo,
    otp_app: :today,
    adapter: Ecto.Adapters.Postgres
end
