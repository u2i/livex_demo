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
  data :expanded, :boolean

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:has_changes, fn -> false end)
     |> assign_new(:expanded, fn -> false end)
     |> assign_new(:country_selected, [:selected_country], &(&1.selected_country || :us))
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
    <div id={@id} class="relative">
      <!-- Collapsed Filter Bar -->
      <div class="bg-white border border-gray-200 rounded-md shadow-sm p-3 flex items-center justify-between relative z-20">
        <div class="flex items-center space-x-2">
          <h3 class="text-lg font-medium text-gray-700">{@title}</h3>
          
    <!-- Filter Status -->
          <div :if={@selected_country || @selected_state} class="flex items-center ml-4">
            <span class="text-sm text-gray-500 mr-2">Filters:</span>
            
    <!-- Country Filter Badge -->
            <span
              :if={@selected_country}
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 mr-2"
            >
              {if @selected_country == :us, do: "United States", else: "Canada"}
            </span>
            
    <!-- State/Province Filter Badge -->
            <span
              :if={@selected_state}
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
            >
              {@selected_state}
            </span>
          </div>

          <span :if={!@selected_country && !@selected_state} class="text-sm text-gray-500">
            No filters applied
          </span>
        </div>

        <div class="flex items-center space-x-2">
          <!-- Clear Filters Button -->
          <button
            :if={@selected_country || @selected_state}
            type="button"
            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-md bg-gray-100 text-gray-700 hover:bg-gray-200"
            phx-click="clear_filters"
            phx-target={@myself}
          >
            <.icon name="hero-x-mark" class="w-3 h-3 mr-1" /> Clear
          </button>
          
    <!-- Toggle Filter Button -->
          <button
            type="button"
            class="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-blue-50 text-blue-700 hover:bg-blue-100"
            phx-click={
              if @expanded do
                JSX.assign_data(
                  expanded: false,
                  country_selected: @selected_country,
                  state_selected: @selected_state
                )
              else
                JSX.assign_data(expanded: true)
              end
            }
            phx-target={@myself}
          >
            <%= if @expanded do %>
              <.icon name="hero-x-mark" class="w-4 h-4 mr-1" /> Close
            <% else %>
              <.icon name="hero-funnel" class="w-4 h-4 mr-1" /> Filter
            <% end %>
          </button>
        </div>
      </div>
      
    <!-- Backdrop for expanded filter (click to close) -->
      <div
        :if={@expanded}
        class="fixed inset-0"
        style="z-index: 10;"
        phx-click={
          JSX.assign_data(
            expanded: false,
            country_selected: @selected_country || :us,
            state_selected: @selected_state
          )
        }
        phx-target={@myself}
      >
      </div>
      
    <!-- Expanded Filter Panel (Overlay) -->
      <div
        :if={@expanded}
        class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg p-4 z-20"
      >
        <div class="space-y-4">
          <div class="country-selector">
            <label class="block text-sm font-semibold leading-6 text-zinc-800">Country</label>
            <div class="flex space-x-2 mt-1">
              <button
                type="button"
                class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :us, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
                phx-click={JSX.assign_data(country_selected: :us, state_selected: nil)}
                phx-target={@myself}
              >
                United States
              </button>
              <button
                type="button"
                class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :ca, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
                phx-click={JSX.assign_data(country_selected: :ca, state_selected: nil)}
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
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("apply_filter", _, socket) do
    # Emit the change event with the current selections and close the panel
    socket =
      socket
      |> assign(:expanded, false)
      |> push_emit(:change,
        value: %{
          country: socket.assigns.country_selected,
          state: socket.assigns.state_selected
        }
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    # Reset the filters, close the panel, and emit nil values
    socket =
      socket
      # Default to US
      |> assign(:country_selected, :us)
      |> assign(:state_selected, nil)
      |> assign(:expanded, false)
      |> assign(:has_changes, false)
      |> push_emit(:change,
        value: %{
          country: nil,
          state: nil
        }
      )

    {:noreply, socket}
  end
end
