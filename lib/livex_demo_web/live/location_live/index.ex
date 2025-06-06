defmodule LivexDemoWeb.LocationLive.Index do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive
  alias LivexDemoWeb.LocationComponents.LocationFilterSection

  state :location_modal, LocationLive.Form, url?: false
  state :filter_country, :atom, url?: true, one_of: [:ca, :us]
  state :filter_state, :string, url?: true

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:location_modal, fn -> nil end)
     |> assign_new(:counter, fn -> 0 end)
     |> assign_new(:page_title, fn -> "Listing Locations" end)
     |> assign_new(:filter_country, fn -> nil end)
     |> assign_new(:filter_state, fn -> nil end)
     |> stream_new(:locations, [:filter_country, :filter_state], fn assigns ->
       Demo.list_locations(assigns.filter_country, assigns.filter_state)
     end)}
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
        target={nil}
        {@location_modal}
        phx-close={:close_modal}
      />
      <.header>
        Listing Locations {@counter}
        <:actions>
          <.button
            variant="primary"
            phx-click={JSX.assign_state(:location_modal, LocationLive.Form.new())}
          >
            <.icon name="hero-plus" /> New Location
          </.button>
        </:actions>
      </.header>

      <.live_component
        id="location-filter"
        module={LocationFilterSection}
        target={nil}
        country={@filter_country}
        state={@filter_state}
        title="Filter Locations"
      />

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
          <.link phx-click={JSX.assign_state(:location_modal, LocationLive.Form.edit(location.id))}>
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

  def handle_message(_, :close, %{location_id: location_id} = _params, socket) do
    location = Demo.get_location!(location_id)

    {:noreply, assign(socket, :location_modal, nil) |> stream_insert(:locations, location)}
  end

  def handle_message(_, :close, _, socket) do
    {:noreply, assign(socket, :location_modal, nil)}
  end

  def handle_message(_, :change, %{country: country, state: state}, socket) do
    {:noreply,
     socket
     |> assign(:filter_country, country)
     |> assign(:filter_state, state)}
  end
end
