defmodule Pedemo.Repo do
  use Ecto.Repo,
    otp_app: :pedemo,
    adapter: Ecto.Adapters.Postgres
end
