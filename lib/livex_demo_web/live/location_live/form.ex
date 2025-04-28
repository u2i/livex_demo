defmodule LivexDemoWeb.LocationLive.Form do
  use LivexDemoWeb, :live_view

  alias LivexDemo.Demo
  alias LivexDemo.Demo.Location

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="location-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:street]} type="text" label="Street" />
        <.input field={@form[:city]} type="text" label="City" />
        <.input field={@form[:state]} type="text" label="State" />
        <.input field={@form[:zip]} type="text" label="Zip" />
        <.input field={@form[:country]} type="text" label="Country" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Location</.button>
          <.button navigate={return_path(@return_to, @location)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    location = Demo.get_location!(id)

    socket
    |> assign(:page_title, "Edit Location")
    |> assign(:location, location)
    |> assign(:form, to_form(Demo.change_location(location)))
  end

  defp apply_action(socket, :new, _params) do
    location = %Location{}

    socket
    |> assign(:page_title, "New Location")
    |> assign(:location, location)
    |> assign(:form, to_form(Demo.change_location(location)))
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset = Demo.change_location(socket.assigns.location, location_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    save_location(socket, socket.assigns.live_action, location_params)
  end

  defp save_location(socket, :edit, location_params) do
    case Demo.update_location(socket.assigns.location, location_params) do
      {:ok, location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_location(socket, :new, location_params) do
    case Demo.create_location(location_params) do
      {:ok, location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _location), do: ~p"/locations"
  defp return_path("show", location), do: ~p"/locations/#{location}"
end
