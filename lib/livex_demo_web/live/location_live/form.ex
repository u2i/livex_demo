defmodule LivexDemoWeb.LocationLive.Form do
  use LivexDemoWeb, :livex_component

  alias LivexDemo.Demo
  alias LivexDemo.Demo.Location
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-remove={modal_hide()}>
      <.modal id={Atom.to_string(@id) <> "-modal"} on_close={JS.push("close", target: @myself)}>
        <:title>{@page_title}</:title>
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
        <.form
          for={@form}
          id={Atom.to_string(@id) <> "-form"}
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:street]} type="text" label="Street" />
          <.input field={@form[:city]} type="text" label="City" />
          <.input field={@form[:state]} type="text" label="State" />
          <.input field={@form[:zip]} type="text" label="Zip" />
          <.input field={@form[:country]} type="text" label="Country" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.button phx-disable-with="Saving..." variant="primary">Save Location</.button>
          <.button type="button" phx-target={@myself} phx-click="close">Cancel</.button>
        </.form>
      </.modal>
    </div>
    """
  end

  attributes do
    attribute :location_id, :string
    attribute :action, :atom
  end

  @impl true
  def update(%{location_id: location_id, action: :edit} = assigns, socket) do
    location = Demo.get_location!(location_id)
    changeset = Demo.change_location(location)

    {:ok,
     socket
     # you must have this
     |> assign(assigns)
     # below is ephemeral
     |> assign(:form, to_form(changeset))
     |> assign(:location, location)
     |> assign(:page_title, page_title(:edit))}
  end

  def update(%{action: :new} = assigns, socket) do
    location = %Location{}

    {:ok,
     socket
     # you must have this
     |> assign(assigns)
     # below is ephemeral
     |> assign(:form, to_form(Demo.change_location(location)))
     |> assign(:page_title, page_title(:new))
     |> assign(:location, location)}
  end

  defp page_title(:new), do: "New Location"
  defp page_title(:edit), do: "Edit Location"

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset = Demo.change_location(socket.assigns.location, location_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    save_location(socket, socket.assigns.action, location_params)
  end

  def handle_event("close", _, socket) do
    {:noreply,
     socket
     |> push_delete()}
  end

  defp save_location(socket, :edit, location_params) do
    case Demo.update_location(socket.assigns.location, location_params) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location updated successfully")
         |> push_delete()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_location(socket, :new, location_params) do
    case Demo.create_location(location_params) |> IO.inspect() do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location created successfully")
         |> push_delete()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
