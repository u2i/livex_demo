defmodule LivexDemoWeb.LocationLive.Index do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Locations
        <:actions>
          <.button variant="primary" phx-click="new_location">
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
          <.link phx-click="edit_location" phx-value-location_id={location.id}>Edit</.link>
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
      <.live_component
        :if={@location_modal}
        id={:location_modal}
        path={[:location_modal]}
        module={LocationLive.Form}
        {@location_modal}
      />
    </Layouts.app>
    """
  end

  components do
    has_one :location_modal, LocationLive.Form
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Locations")
     |> stream(:locations, Demo.list_locations())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Demo.get_location!(id)
    {:ok, _} = Demo.delete_location(location)

    {:noreply, stream_delete(socket, :locations, location)}
  end

  def handle_event("edit_location", params, socket) do
    {:noreply,
     socket
     |> assign(:location_modal, %{action: :edit, location_id: params["location_id"]})}
  end

  def handle_event("new_location", _params, socket) do
    {:noreply,
     socket
     |> assign(:location_modal, %{action: :new})}
  end

  @impl true
  def handle_info({:update_component, [:location_modal], assigns}, socket) do
    {:noreply,
     socket
     |> assign(:location_modal, assigns && Map.merge(socket.assigns.modal, assigns))
     |> stream(:locations, Demo.list_locations())}
  end

  def handle_info(
        {:update_component, [:location_modal, :state_province_selector], new_data},
        socket
      ) do
    socket =
      update(socket, :location_modal, fn modal ->
        update_in(modal, [:state_province_selector], fn
          # if it’s nil the first time around, just shove in the new_data
          nil -> new_data
          old -> Map.merge(old, new_data)
        end)
      end)

    {:noreply, socket}
  end
end
