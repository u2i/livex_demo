defmodule LivexDemo.DemoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LivexDemo.Demo` context.
  """

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        description: "some description",
        name: "some name",
        state: "some state",
        street: "some street",
        zip: "some zip"
      })
      |> LivexDemo.Demo.create_location()

    location
  end
end
