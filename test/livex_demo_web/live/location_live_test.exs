defmodule LivexDemoWeb.LocationLiveTest do
  use LivexDemoWeb.ConnCase

  import Phoenix.LiveViewTest
  import LivexDemo.DemoFixtures

  @create_attrs %{
    name: "some name",
    state: "some state",
    zip: "some zip",
    description: "some description",
    street: "some street",
    city: "some city",
    country: "some country"
  }
  @update_attrs %{
    name: "some updated name",
    state: "some updated state",
    zip: "some updated zip",
    description: "some updated description",
    street: "some updated street",
    city: "some updated city",
    country: "some updated country"
  }
  @invalid_attrs %{
    name: nil,
    state: nil,
    zip: nil,
    description: nil,
    street: nil,
    city: nil,
    country: nil
  }
  defp create_location(_) do
    location = location_fixture()

    %{location: location}
  end

  describe "Index" do
    setup [:create_location]

    test "lists all locations", %{conn: conn, location: location} do
      {:ok, _index_live, html} = live(conn, ~p"/locations")

      assert html =~ "Listing Locations"
      assert html =~ location.name
    end

    test "saves new location", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Location")
               |> render_click()
               |> follow_redirect(conn, ~p"/locations/new")

      assert render(form_live) =~ "New Location"

      assert form_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#location-form", location: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/locations")

      html = render(index_live)
      assert html =~ "Location created successfully"
      assert html =~ "some name"
    end

    test "updates location in listing", %{conn: conn, location: location} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#locations-#{location.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/locations/#{location}/edit")

      assert render(form_live) =~ "Edit Location"

      assert form_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#location-form", location: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/locations")

      html = render(index_live)
      assert html =~ "Location updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes location in listing", %{conn: conn, location: location} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert index_live |> element("#locations-#{location.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#locations-#{location.id}")
    end
  end

  describe "Show" do
    setup [:create_location]

    test "displays location", %{conn: conn, location: location} do
      {:ok, _show_live, html} = live(conn, ~p"/locations/#{location}")

      assert html =~ "Show Location"
      assert html =~ location.name
    end

    test "updates location and returns to show", %{conn: conn, location: location} do
      {:ok, show_live, _html} = live(conn, ~p"/locations/#{location}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/locations/#{location}/edit?return_to=show")

      assert render(form_live) =~ "Edit Location"

      assert form_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#location-form", location: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/locations/#{location}")

      html = render(show_live)
      assert html =~ "Location updated successfully"
      assert html =~ "some updated name"
    end
  end
end
