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

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-value-target_path="location_modal/state_province_selector" class="space-y-4">
      <div class="country-selector">
        <label class="block text-sm font-semibold leading-6 text-zinc-800">Country</label>
        <div class="flex space-x-2 mt-1">
          <button
            type="button"
            class={"px-3 py-2 text-sm font-medium rounded-md #{if @country == :us, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
            phx-value-__target_path="location_modal/state_province_selector"
            phx-click="select_country"
            phx-value-country="us"
          >
            United States
          </button>
          <button
            type="button"
            class={"px-3 py-2 text-sm font-medium rounded-md #{if @country == :ca, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700"}"}
            phx-value-__target_path="location_modal/state_province_selector"
            phx-click="select_country"
            phx-value-country="ca"
          >
            Canada
          </button>
        </div>
        <.input type="text" field={@country_field} value={@country} />
      </div>
      <div class="state-province-selector">
        <.input
          field={@field}
          type="select"
          label={if @country == :us, do: "State", else: "Province"}
          options={@state_options}
        />
      </div>
    </div>
    """
  end

  attributes do
    attribute :country, :atom
  end

  @impl true
  def mount(assigns, socket) do
    IO.puts(">>> MOUNTING #{[]}")
    IO.inspect(assigns, label: :assigns)

    country =
      unless Map.has_key?(assigns, :country) do
        :us
      else
        assigns.country
      end

    {:ok,
     socket
     |> assign_(assigns)
     |> assign_new_(:country, fn -> :us end)
     |> assign_(:state_options, get_options(country))}
  end

  @impl true
  def handle_event("select_country", %{"country" => country_str}, socket) do
    country = String.to_existing_atom(country_str)

    {:noreply,
     socket
     |> assign_(:country, country)
     |> assign_(:state_options, get_options(country))}
  end

  defp get_options(:ca), do: @canadian_provinces
  defp get_options(_), do: @us_states
end
