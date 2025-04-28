defmodule LivexDemoWeb.LocationLive.Show do
  use LivexDemoWeb, :livex_view

  alias LivexDemo.Demo

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
          <.button variant="primary" navigate={~p"/locations/#{@location}/edit?return_to=show"}>
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
    </Layouts.app>
    """
  end

  attributes do
    attribute :id, :string
  end

  @impl true
  def mount(_, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Location")
     |> assign(:location, Demo.get_location!(socket.assigns.id))}
  end
end
