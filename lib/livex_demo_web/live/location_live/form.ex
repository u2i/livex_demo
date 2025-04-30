defmodule LivexDemoWeb.LocationLive.Form do
  use LivexDemoWeb, :livex_component

  alias LivexDemo.Demo
  alias LivexDemo.Demo.Location
  alias Phoenix.LiveView.JS
  alias LivexDemoWeb.LocationComponents.StateProvinceSelector

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-remove={modal_hide()}>
      <.modal
        id={Atom.to_string(@id) <> "-modal"}
        on_close={JS.push("close", value: %{__target_path: "location_modal"})}
      >
        <:title>{@page_title}</:title>
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
        <.form
          for={@form}
          id={Atom.to_string(@id) <> "-form"}
          phx-change="validate"
          phx-submit="save"
          phx-value-__target_path="location_modal"
        >
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:street]} type="text" label="Street" />

          <.input field={@form[:city]} type="text" label="City" />
          <.input field={@form[:zip]} type="text" label="Zip" />
          <.live_component
            id={:state_province_selector}
            module={StateProvinceSelector}
            {@state_province_selector}
            field={@form[:state]}
            country_field={@form[:country]}
          />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.button phx-disable-with="Saving..." variant="primary">Save Location</.button>
          <.button type="button" phx-click="close" phx-value-__target_path="location_modal">
            Cancel
          </.button>
        </.form>
      </.modal>
    </div>
    """
  end

  attributes do
    attribute :location_id, :string
    attribute :action, :atom
  end

  components do
    has_one :state_province_selector, LivexDemoWeb.LocationComponents.StateProvinceSelector
  end

  def mount(%{location_id: location_id, action: :edit} = assigns, socket) do
    location = Demo.get_location!(location_id)
    changeset = Demo.change_location(location)

    socket =
      socket
      |> assign_(assigns)

    {:ok,
     unless Map.has_key?(assigns(socket), :state_province_selector) do
       socket
       |> create_component(:state_province_selector, %{
         country: String.to_existing_atom(location.country)
       })
     else
       socket
     end
     |> assign_(:form, to_form(changeset))
     |> assign_(:location, location)
     |> assign_(:page_title, page_title(:edit))}
  end

  def mount(%{action: :new} = assigns, socket) do
    location = %Location{}

    {:ok,
     socket
     # you must have this
     |> assign_(assigns)
     # below is ephemeral
     |> assign_(:form, to_form(Demo.change_location(location)))
     |> assign_(:page_title, page_title(:new))
     |> assign_(:country, "US")
     # |> assign_new(:state_province_selector, fn -> %{country: :us} end)
     |> assign_(:location, location)}
  end

  defp page_title(:new), do: "New Location"
  defp page_title(:edit), do: "Edit Location"

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset = Demo.change_location(assigns(socket).location, location_params)
    {:noreply, assign_(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("country_changed", %{"location" => %{"country" => country}}, socket) do
    {:noreply, assign_(socket, :country, country)}
  end

  def handle_event("save", %{"location" => location_params}, {s, h} = socket) do
    save_location(socket, assigns(socket).action, location_params)
  end

  def handle_event("close", _, socket) do
    {:noreply,
     socket
     |> push_delete()}
  end

  defp save_location(socket, :edit, location_params) do
    case Demo.update_location(assigns(socket).location, location_params) do
      {:ok, _location} ->
        {:noreply,
         socket
         #    |> put_flash(:info, "Location updated successfully")
         |> push_delete()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_(socket, form: to_form(changeset))}
    end
  end

  defp save_location(socket, :new, location_params) do
    case Demo.create_location(location_params) |> IO.inspect() do
      {:ok, _location} ->
        {:noreply,
         socket
         #   |> put_flash(:info, "Location created successfully")
         |> push_delete()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_(socket, form: to_form(changeset))}
    end
  end
end
