defmodule LivexDemo.DemoTest do
  use LivexDemo.DataCase

  alias LivexDemo.Demo

  describe "locations" do
    alias LivexDemo.Demo.Location

    import LivexDemo.DemoFixtures

    @invalid_attrs %{name: nil, state: nil, zip: nil, description: nil, street: nil, city: nil, country: nil}

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Demo.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Demo.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      valid_attrs = %{name: "some name", state: "some state", zip: "some zip", description: "some description", street: "some street", city: "some city", country: "some country"}

      assert {:ok, %Location{} = location} = Demo.create_location(valid_attrs)
      assert location.name == "some name"
      assert location.state == "some state"
      assert location.zip == "some zip"
      assert location.description == "some description"
      assert location.street == "some street"
      assert location.city == "some city"
      assert location.country == "some country"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demo.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      update_attrs = %{name: "some updated name", state: "some updated state", zip: "some updated zip", description: "some updated description", street: "some updated street", city: "some updated city", country: "some updated country"}

      assert {:ok, %Location{} = location} = Demo.update_location(location, update_attrs)
      assert location.name == "some updated name"
      assert location.state == "some updated state"
      assert location.zip == "some updated zip"
      assert location.description == "some updated description"
      assert location.street == "some updated street"
      assert location.city == "some updated city"
      assert location.country == "some updated country"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Demo.update_location(location, @invalid_attrs)
      assert location == Demo.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Demo.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Demo.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Demo.change_location(location)
    end
  end
end
