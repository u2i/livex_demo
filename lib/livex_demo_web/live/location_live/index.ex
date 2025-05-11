defmodule LivexDemoWeb.LocationLive.Index do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive

  data :location_modal, LocationLive.Form, url?: false

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:location_modal, fn -> nil end)
     |> assign_new(:counter, fn -> 0 end)
     |> assign_new(:page_title, fn -> "Listing Locations" end)
     |> assign_new(:location_modal, fn -> nil end)
     |> stream(:locations, Demo.list_locations())}
  end

  @impl true
  def render(assigns) do
    assigns = Map.put(assigns, :counter, assigns.counter + 1)

    ~H"""
    <Layouts.app flash={@flash}>
      <.live_component
        :if={@location_modal}
        id={:location_modal}
        module={LocationLive.Form}
        parent={nil}
        {@location_modal}
        phx-close="close_modal"
      />
      <.header>
        Listing Locations {@counter}
        <:actions>
          <.button
            variant="primary"
            phx-click={JSX.assign_data(:location_modal, LocationLive.Form.new())}
          >
            <.icon name="hero-plus" /> New Location
          </.button>
        </:actions>
      </.header>

      <.table
        id="locations"
        rows={@streams.locations}
        row_click={fn {_id, location} -> JS.navigate(~p"/locations/#{location}") end}
      >
        <:col :let={{_id, location}} label="Name">{location.name}</:col>
        <:col :let={{_id, location}} label="Street">{location.street}</:col>
        <:col :let={{_id, location}} label="City">{location.city}</:col>
        <:col :let={{_id, location}} label="State">{location.state}</:col>
        <:col :let={{_id, location}} label="Zip">{location.zip}</:col>
        <:col :let={{_id, location}} label="Country">{location.country}</:col>
        <:col :let={{_id, location}} label="Description">{location.description}</:col>
        <:action :let={{_id, location}}>
          <div class="sr-only">
            <.link navigate={~p"/locations/#{location}"}>Show</.link>
          </div>
          <.link phx-click={JSX.assign_data(:location_modal, LocationLive.Form.edit(location.id))}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, location}}>
          <.link
            phx-click={JS.push("delete", value: %{id: location.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Demo.get_location!(id)
    {:ok, _} = Demo.delete_location(location)

    {:noreply, stream_delete(socket, :locations, location)}
  end

  def handle_event("close_modal", %{"location_id" => location_id}, socket) do
    location = Demo.get_location!(location_id)

    {:noreply, assign(socket, :location_modal, nil) |> stream_insert(:locations, location)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, :location_modal, nil)}
  end
end
