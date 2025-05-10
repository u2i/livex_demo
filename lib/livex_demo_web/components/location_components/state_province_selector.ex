defmodule LivexDemoWeb.LocationComponents.StateProvinceSelector do
  @moduledoc """
  A component for selecting US states or Canadian provinces based on the country.
  """
  use LivexDemoWeb, :livex_component

  @us_states [
    {"Alabama", "AL"},
    {"Alaska", "AK"},
    {"Arizona", "AZ"},
    {"Arkansas", "AR"},
    {"California", "CA"},
    {"Colorado", "CO"},
    {"Connecticut", "CT"},
    {"Delaware", "DE"},
    {"Florida", "FL"},
    {"Georgia", "GA"},
    {"Hawaii", "HI"},
    {"Idaho", "ID"},
    {"Illinois", "IL"},
    {"Indiana", "IN"},
    {"Iowa", "IA"},
    {"Kansas", "KS"},
    {"Kentucky", "KY"},
    {"Louisiana", "LA"},
    {"Maine", "ME"},
    {"Maryland", "MD"},
    {"Massachusetts", "MA"},
    {"Michigan", "MI"},
    {"Minnesota", "MN"},
    {"Mississippi", "MS"},
    {"Missouri", "MO"},
    {"Montana", "MT"},
    {"Nebraska", "NE"},
    {"Nevada", "NV"},
    {"New Hampshire", "NH"},
    {"New Jersey", "NJ"},
    {"New Mexico", "NM"},
    {"New York", "NY"},
    {"North Carolina", "NC"},
    {"North Dakota", "ND"},
    {"Ohio", "OH"},
    {"Oklahoma", "OK"},
    {"Oregon", "OR"},
    {"Pennsylvania", "PA"},
    {"Rhode Island", "RI"},
    {"South Carolina", "SC"},
    {"South Dakota", "SD"},
    {"Tennessee", "TN"},
    {"Texas", "TX"},
    {"Utah", "UT"},
    {"Vermont", "VT"},
    {"Virginia", "VA"},
    {"Washington", "WA"},
    {"West Virginia", "WV"},
    {"Wisconsin", "WI"},
    {"Wyoming", "WY"},
    {"District of Columbia", "DC"}
  ]

  @canadian_provinces [
    {"Alberta", "AB"},
    {"British Columbia", "BC"},
    {"Manitoba", "MB"},
    {"New Brunswick", "NB"},
    {"Newfoundland and Labrador", "NL"},
    {"Northwest Territories", "NT"},
    {"Nova Scotia", "NS"},
    {"Nunavut", "NU"},
    {"Ontario", "ON"},
    {"Prince Edward Island", "PE"},
    {"Quebec", "QC"},
    {"Saskatchewan", "SK"},
    {"Yukon", "YT"}
  ]

  prop :country_field, :any
  prop :state_field, :any
  data :country_selected, :atom

  def pre_render(socket) do
    {:noreply,
     socket
     |> assign_new(:country_selected, &country_selected(&1))
     |> assign_new(:state_options, [:country_selected], &get_options(&1.country_selected))}
  end

  defp country_selected(%{country_field: %{value: country}}) when not is_nil(country),
    do: country |> String.to_existing_atom()

  defp country_selected(_), do: :us

  defp get_options(:ca), do: @canadian_provinces
  defp get_options(_), do: @us_states

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-value-target_path="location_modal/state_province_selector" class="space-y-4">
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
