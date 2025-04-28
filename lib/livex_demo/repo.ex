defmodule LivexDemo.Repo do
  use Ecto.Repo,
    otp_app: :livex_demo,
    adapter: Ecto.Adapters.SQLite3
end
