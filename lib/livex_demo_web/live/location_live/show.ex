defmodule LivexDemoWeb.LocationLive.Show do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo
  alias LivexDemoWeb.LocationLive

  state :location_id, :string, url?: true
  state :location_modal, LocationLive.Form

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Show Location")
     |> assign_new(:location_modal, fn -> nil end)
     |> assign_new(:location, [:location_id], &Demo.get_location!(&1.location_id))}
  end

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
          <.button
            variant="primary"
            phx-click={JSX.assign_state(:location_modal, LocationLive.Form.edit(@location.id))}
          >
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
        module={LocationLive.Form}
        target={nil}
        {@location_modal}
        phx-close="close_modal"
      />
    </Layouts.app>
    """
  end

  def handle_message(_, :close, _, socket) do
    {:noreply,
     Map.put(socket, :assigns, Map.drop(socket.assigns, [:location]))
     |> assign(:location_modal, nil)}
  end
end
