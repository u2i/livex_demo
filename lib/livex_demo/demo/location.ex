defmodule LivexDemo.Demo.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :street, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :country, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :street, :city, :state, :zip, :country, :description])
    |> validate_required([:name, :street, :city, :zip, :description])
  end
end
