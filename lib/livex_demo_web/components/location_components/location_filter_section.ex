defmodule LivexDemoWeb.LocationComponents.LocationFilterSection do
  @moduledoc """
  A complete filter section component for filtering locations by country and state/province.
  This component encapsulates the entire filter UI and functionality.
  """
  use LivexDemoWeb, :livex_component
  alias LivexDemo.Demo

  prop :id, :string
  prop :country, :atom
  prop :state, :string
  prop :title, :string

  state :pending_country, :atom
  state :pending_state, :string
  state :has_changes, :boolean
  state :expanded, :boolean

  def pre_render(socket) do
    {:noreply,
     socket
     |> IO.inspect(label: :filter)
     |> assign_new(:has_changes, fn -> false end)
     |> assign_new(:expanded, fn -> false end)
     |> assign_new(:pending_country, [:country], &(&1.country || :us))
     |> assign_new(:pending_state, [:state], & &1.state)
     |> assign_new(:state_options, [:pending_country], &get_options(&1.pending_country))
     |> then(
       &assign(
         &1,
         :has_changes,
         changed?(socket, :country, :pending_country) || changed?(socket, :state, :pending_state)
       )
     )}
  end

  defp get_options(country), do: Demo.get_states_with_names_for_country(country)
  defp changed?(socket, first, second), do: socket.assigns[first] != socket.assigns[second]

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="relative">
      <div class="bg-white border border-gray-200 rounded-md shadow-sm p-3 flex items-center justify-between relative z-20">
        <div class="flex items-center space-x-2">
          <h3 class="text-lg font-medium text-gray-700">{@title}</h3>
          <div :if={@country || @state} class="flex items-center ml-4">
            <span class="text-sm text-gray-500 mr-2">Filters:</span>
            <span
              :if={@country}
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 mr-2"
            >
              {if @country == :us, do: "United States", else: "Canada"}
            </span>
            <span
              :if={@state}
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
            >
              {@state}
            </span>
          </div>

          <span :if={!@country && !@state} class="text-sm text-gray-500">
            No filters applied
          </span>
        </div>

        <div class="flex items-center space-x-2">
          <button
            :if={@country || @state}
            type="button"
            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-md bg-gray-100 text-gray-700 hover:bg-gray-200"
            phx-click={JSX.emit(:change, value: %{country: nil, state: nil})}
          >
            <.icon name="hero-x-mark" class="w-3 h-3 mr-1" /> Clear
          </button>
          <button
            type="button"
            class="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-blue-50 text-blue-700 hover:bg-blue-100"
            phx-click={
              if @expanded do
                JSX.assign_data(
                  expanded: false,
                  pending_country: @country,
                  pending_state: @state
                )
              else
                JSX.assign_data(expanded: true)
              end
            }
          >
            <span :if={@expanded}>
              <.icon name="hero-x-mark" class="w-4 h-4 mr-1" /> Close
            </span>
            <span :if={!@expanded}>
              <.icon name="hero-funnel" class="w-4 h-4 mr-1" /> Filter
            </span>
          </button>
        </div>
      </div>
      <div
        :if={@expanded}
        class="fixed inset-0"
        style="z-index: 10;"
        phx-click={
          JSX.assign_data(
            expanded: false,
            pending_country: @country || :us,
            pending_state: @state
          )
        }
      >
      </div>
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
                class={"px-3 py-2 text-sm font-medium rounded-md #{if @pending_country == :us, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
                phx-click={JSX.assign_data(pending_country: :us, pending_state: nil)}
              >
                United States
              </button>
              <button
                type="button"
                class={"px-3 py-2 text-sm font-medium rounded-md #{if @pending_country == :ca, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
                phx-click={JSX.assign_data(pending_country: :ca, pending_state: nil)}
              >
                Canada
              </button>
            </div>
          </div>

          <div class="state-province-selector">
            <label class="block text-sm font-semibold leading-6 text-zinc-800">
              {if @pending_country == :us, do: "State", else: "Province"}
            </label>
            <form>
              <select
                class="mt-1 block w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-gray-900 shadow-sm focus:border-zinc-500 focus:ring-zinc-500 sm:text-sm"
                name="pending_state"
                phx-change={JSX.assign_data()}
              >
                <option value="" disabled selected={is_nil(@pending_state)}>
                  Select {if @pending_country == :us, do: "State", else: "Province"}
                </option>
                <option
                  :for={{name, code} <- @state_options}
                  value={code}
                  selected={@pending_state == code}
                >
                  {name}
                </option>
              </select>
            </form>
          </div>

          <div class="flex justify-end mt-4">
            <button
              type="button"
              class={"px-3 py-2 text-sm font-medium rounded-md #{if @has_changes, do: "bg-blue-600 text-white hover:bg-blue-700", else: "bg-gray-200 text-gray-500 cursor-not-allowed"}"}
              phx-click={
                JSX.emit(:change, value: %{country: @pending_country, state: @pending_state})
              }
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
end
