defmodule LivexDemo.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :street, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :country, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
