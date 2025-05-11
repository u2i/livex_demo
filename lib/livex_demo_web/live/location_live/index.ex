defmodule LivexDemoWeb.LocationLive.Index do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive
  alias LivexDemoWeb.LocationComponents.LocationFilterSection

  data :location_modal, LocationLive.Form, url?: false
  data :filter_country, :atom, url?: true, one_of: [:ca, :us]
  data :filter_state, :string, url?: true

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:location_modal, fn -> nil end)
     |> assign_new(:counter, fn -> 0 end)
     |> assign_new(:page_title, fn -> "Listing Locations" end)
     |> assign_new(:filter_country, fn -> nil end)
     |> assign_new(:filter_state, fn -> nil end)
     |> assign_new(:locations_query, [:filter_country, :filter_state], fn assigns ->
       filter_locations(
         Demo.list_locations(),
         assigns.filter_country,
         assigns.filter_state
       )
     end)
     |> then(&stream(&1, :locations, &1.assigns.locations_query, reset: true))}
  end

  defp filter_locations(locations, nil, nil), do: locations

  defp filter_locations(locations, country, nil) when not is_nil(country) do
    country_str = Atom.to_string(country)
    Enum.filter(locations, &(&1.country == country_str))
  end

  defp filter_locations(locations, country, state)
       when not is_nil(country) and not is_nil(state) do
    country_str = Atom.to_string(country)
    Enum.filter(locations, &(&1.country == country_str && &1.state == state))
  end

  defp filter_locations(_, a, b) do
    IO.inspect(a, label: :a)
    IO.inspect(b, label: :b)
    raise("HELL")
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

      <.live_component
        id="location-filter"
        module={LocationFilterSection}
        selected_country={@filter_country}
        selected_state={@filter_state}
        title="Filter Locations"
        phx-change="change"
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

  def handle_event("change", %{"country" => country, "state" => state}, socket) do
    country_atom =
      if is_binary(country) && country != "", do: String.to_existing_atom(country), else: nil

    state_value = if state == "", do: nil, else: state

    {:noreply,
     socket
     |> assign(:filter_country, country_atom)
     |> assign(:filter_state, state_value)}
  end
end
