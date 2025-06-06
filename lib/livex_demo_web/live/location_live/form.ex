defmodule LivexDemoWeb.LocationLive.Form do
  use LivexDemoWeb, :livex_component

  alias LivexDemo.Demo
  alias LivexDemo.Demo.Location
  alias LivexDemoWeb.LocationComponents.StateProvinceSelector

  def new, do: %{action: :new}
  def edit(id), do: %{action: :edit, location_id: id}

  attr :location_id, :string
  attr :action, :atom

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:location, [:action, :location_id], &get_location(&1.action, &1))
     |> assign_new(:form, [:location], &to_form(Demo.change_location(&1.location)))
     |> assign_new(:is_button_disabled, fn -> false end)
     |> assign_new(:page_title, [:action], &page_title(&1.action))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-remove={modal_hide()}
      phx-mounted={modal_show()}
      class="fixed inset-0 z-50 flex items-center justify-center modal-container opacity-0"
    >
      <.modal id={Atom.to_string(@id) <> "-modal"} phx-target={@myself} phx-close="close">
        <:title>{@page_title}</:title>
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
        <.form
          for={@form}
          id={Atom.to_string(@id) <> "-form"}
          phx-change="validate"
          phx-submit="save"
          phx-target={@myself}
        >
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:street]} type="text" label="Street" />

          <.input field={@form[:city]} type="text" label="City" />
          <.input field={@form[:zip]} type="text" label="Zip" />
          <.live_component
            id={:state_province_selector}
            module={StateProvinceSelector}
            state_field={@form[:state]}
            country_field={@form[:country]}
          />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.button phx-disable-with="Saving..." disabled={@is_button_disabled} variant="primary">
            Save Location
          </.button>
          <.button type="button" phx-target={@myself} phx-click="close">
            Cancel
          </.button>
        </.form>
      </.modal>
    </div>
    """
  end

  defp get_location(:edit, assigns), do: Demo.get_location!(assigns.location_id)
  defp get_location(:new, _assigns), do: %Location{}

  defp page_title(:new), do: "New Location"
  defp page_title(:edit), do: "Edit Location"

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset = Demo.change_location(socket.assigns.location, location_params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    case write_location(socket, location_params) do
      {:ok, location} ->
        {:noreply,
         assign(socket, :is_button_disabled, true)
         |> send_message(:close, %{location_id: location.id})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("close", _params, socket) do
    {:noreply, send_message(socket, :close, %{})}
  end

  defp write_location(%{assigns: %{action: :edit}} = socket, location_params),
    do: Demo.update_location(socket.assigns.location, location_params)

  defp write_location(%{assigns: %{action: :new}}, location_params),
    do: Demo.create_location(location_params)
end
