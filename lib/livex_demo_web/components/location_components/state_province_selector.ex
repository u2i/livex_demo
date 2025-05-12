defmodule LivexDemoWeb.LocationComponents.StateProvinceSelector do
  @moduledoc """
  A component for selecting US states or Canadian provinces based on the country.
  """
  use LivexDemoWeb, :livex_component
  alias LivexDemo.Demo

  attr :country_field, :any
  attr :state_field, :any
  state :country_selected, :atom

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:country_selected, &country_selected(&1))
     |> assign_new(:state_options, [:country_selected], &get_options(&1.country_selected))}
  end

  defp country_selected(%{country_field: %{value: country}}) when not is_nil(country),
    do: country |> String.to_existing_atom()

  defp country_selected(_), do: :us

  defp get_options(:ca), do: Demo.get_ca_provinces_with_names()
  defp get_options(_), do: Demo.get_us_states_with_names()

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="space-y-4">
      <div class="country-selector">
        <label class="block text-sm font-semibold leading-6 text-zinc-800">Country</label>
        <div id={@country_field.name} class="flex space-x-2 mt-1">
          <button
            type="button"
            class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :us, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
            phx-click={JSX.assign_data(:country_selected, :us)}
          >
            United States
          </button>
          <button
            type="button"
            class={"px-3 py-2 text-sm font-medium rounded-md #{if @country_selected == :ca, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
            phx-click={JSX.assign_data(:country_selected, :ca)}
          >
            Canada
          </button>
        </div>
        <input type="hidden" name={@country_field.name} value={@country_selected} />
      </div>
      <div class="state-province-selector">
        <.input
          field={@state_field}
          type="select"
          label={if @country_selected == :us, do: "State", else: "Province"}
          options={@state_options}
        />
      </div>
    </div>
    """
  end
end
