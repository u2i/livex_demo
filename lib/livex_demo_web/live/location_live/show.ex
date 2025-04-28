defmodule LivexDemoWeb.LocationLive.Show do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Location {@location.id}
        <:subtitle>This is a location record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/locations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" phx-click="edit_location">
            <.icon name="hero-pencil-square" /> Edit location
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@location.name}</:item>
        <:item title="Street">{@location.street}</:item>
        <:item title="City">{@location.city}</:item>
        <:item title="State">{@location.state}</:item>
        <:item title="Zip">{@location.zip}</:item>
        <:item title="Country">{@location.country}</:item>
        <:item title="Description">{@location.description}</:item>
      </.list>
      <.live_component
        :if={@location_modal}
        id={:location_modal}
        path={[]}
        module={LocationLive.Form}
        {@location_modal}
        location_id={@id}
      />
    </Layouts.app>
    """
  end

  attributes do
    attribute :id, :string
  end

  components do
    has_one :location_modal, LocationLive.Form
  end

  @impl true
  def mount(_, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Location")
     |> assign(:location, Demo.get_location!(socket.assigns.id))}
  end

  @impl true
  def handle_event("edit_location", _params, socket) do
    {:noreply,
     socket
     |> assign(:location_modal, %{action: :edit})}
  end

  @impl true
  def handle_info({:update_component, _path, assigns}, socket) do
    {:noreply,
     socket
     |> assign(:location_modal, assigns && Map.merge(socket.assigns.modal, assigns))
     |> assign(:location, Demo.get_location!(socket.assigns.id))}
  end
end
