defmodule LivexDemoWeb.LocationComponents.LocationFilterSection do
  @moduledoc """
  A complete filter section component for filtering locations by country and state/province.
  This component encapsulates the entire filter UI and functionality.
  """
  use LivexDemoWeb, :livex_component
  alias LivexDemo.Demo

  prop :id, :string
  prop :selected_country, :atom
  prop :selected_state, :string
  prop :title, :string

  data :country_selected, :atom
  data :state_selected, :string
  data :has_changes, :boolean

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:has_changes, fn -> false end)
     |> assign_new(:country_selected, [:selected_country], & &1.selected_country)
     |> assign_new(:state_selected, [:selected_state], & &1.selected_state)
     |> assign_new(:state_options, [:country_selected], &get_options(&1.country_selected))
     |> then(
       &assign(
         &1,
         :has_changes,
         &1.assigns.country_selected != &1.assigns.selected_country ||
           &1.assigns.state_selected != &1.assigns.selected_state
       )
     )}
  end

  defp get_options(country), do: Demo.get_states_with_names_for_country(country)

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="my-6 p-4 bg-gray-50 rounded-md shadow-sm">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-700">Filter Locations</h3>
        <button
          :if={@country_selected || @state_selected}
          type="button"
          class="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-gray-200 text-gray-700 hover:bg-gray-300"
          phx-click={JSX.assign_data(country_selected: nil, state_selected: nil)}
          phx-target={@myself}
        >
          <.icon name="hero-x-mark" class="w-4 h-4 mr-1" /> Clear Filters
        </button>
      </div>

      <div class="space-y-4">
        <div class="country-selector">
          <label class="block text-sm font-semibold leading-6 text-zinc-800">Country</label>
          <div class="flex space-x-2 mt-1">
            <button
              type="button"
              class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :us, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
              phx-click={JSX.assign_data(:country_selected, :us)}
              phx-target={@myself}
            >
              United States
            </button>
            <button
              type="button"
              class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :ca, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
              phx-click={JSX.assign_data(:country_selected, :ca)}
              phx-target={@myself}
            >
              Canada
            </button>
          </div>
        </div>

        <div class="state-province-selector">
          <label class="block text-sm font-semibold leading-6 text-zinc-800">
            {if @country_selected == :us, do: "State", else: "Province"}
          </label>
          <form>
            <select
              class="mt-1 block w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-gray-900 shadow-sm focus:border-zinc-500 focus:ring-zinc-500 sm:text-sm"
              name="state_selected"
              phx-change={JSX.assign_data()}
              phx-target={@myself}
            >
              <option value="" disabled selected={is_nil(@state_selected)}>
                Select {if @country_selected == :us, do: "State", else: "Province"}
              </option>
              <%= for {name, code} <- @state_options do %>
                <option value={code} selected={@state_selected == code}>
                  {name}
                </option>
              <% end %>
            </select>
          </form>
        </div>

        <div class="flex justify-end mt-4">
          <button
            type="button"
            class={"px-3 py-2 text-sm font-medium rounded-md #{if @has_changes, do: "bg-blue-600 text-white hover:bg-blue-700", else: "bg-gray-200 text-gray-500 cursor-not-allowed"}"}
            phx-click="apply_filter"
            phx-target={@myself}
            disabled={!@has_changes}
          >
            Apply Filter
          </button>
        </div>
      </div>

      <div :if={@selected_country || @selected_state} class="mt-3 text-sm text-gray-600">
        <p>
          <span class="font-medium">Active filters:</span>
          <%= if @selected_country do %>
            Country: <span class="font-semibold">{@selected_country}</span>
          <% end %>
          <%= if @selected_state do %>
            <%= if @selected_country do %>
              ,
            <% end %>
            {if @selected_country == :us, do: "State", else: "Province"}:
            <span class="font-semibold">{@selected_state}</span>
          <% end %>
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("apply_filter", _, socket) do
    # Emit the change event with the current selections
    socket =
      socket
      |> push_emit(:change,
        value: %{
          country: socket.assigns.country_selected,
          state: socket.assigns.state_selected
        }
      )

    {:noreply, socket}
  end
end
