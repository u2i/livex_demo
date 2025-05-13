defmodule LivexDemo.Demo do
  @moduledoc """
  The Demo context.
  """

  import Ecto.Query, warn: false
  alias LivexDemo.Repo

  alias LivexDemo.Demo.Location

  @us_states_with_names [
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

  @ca_provinces_with_names [
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

  @us_states Enum.map(@us_states_with_names, fn {_name, code} -> code end)
  @ca_provinces Enum.map(@ca_provinces_with_names, fn {_name, code} -> code end)

  @doc """
  Returns the list of locations.

  Optionally filters by country and/or state if provided.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

      iex> list_locations(:us, "CA")
      [%Location{country: "us", state: "CA"}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  def list_locations(country, state) do
    Location
    |> filter_by_country(country)
    |> filter_by_state(state)
    |> Repo.all()
  end

  defp filter_by_country(query, nil), do: query
  defp filter_by_country(query, country) do
    country_str = Atom.to_string(country)
    where(query, [l], l.country == ^country_str)
  end

  defp filter_by_state(query, nil), do: query
  defp filter_by_state(query, state), do: where(query, [l], l.state == ^state)

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Returns a list of US state codes (two-letter, capitalized).

  ## Examples

      iex> get_us_states()
      ["AL", "AK", "AZ", ...]

  """
  def get_us_states do
    @us_states
  end

  @doc """
  Returns a list of Canadian province codes (two-letter, capitalized).

  ## Examples

      iex> get_ca_provinces()
      ["AB", "BC", "MB", ...]

  """
  def get_ca_provinces do
    @ca_provinces
  end

  @doc """
  Returns a list of state/province codes for a specific country.

  ## Examples

      iex> get_states_for_country(:us)
      ["AL", "AK", "AZ", ...]

      iex> get_states_for_country(:ca)
      ["AB", "BC", "MB", ...]

      iex> get_states_for_country("us")
      ["AL", "AK", "AZ", ...]

  """
  def get_states_for_country(:us), do: @us_states
  def get_states_for_country(:ca), do: @ca_provinces
  def get_states_for_country("us"), do: @us_states
  def get_states_for_country("ca"), do: @ca_provinces
  def get_states_for_country(_), do: []

  @doc """
  Returns a map of country codes to their respective state/province lists.

  ## Examples

      iex> get_countries_with_states()
      %{
        us: ["AL", "AK", "AZ", ...],
        ca: ["AB", "BC", "MB", ...]
      }

  """
  def get_countries_with_states do
    %{
      us: @us_states,
      ca: @ca_provinces
    }
  end

  @doc """
  Returns a list of US states with their names and codes.

  ## Examples

      iex> get_us_states_with_names()
      [{"Alabama", "AL"}, {"Alaska", "AK"}, ...]

  """
  def get_us_states_with_names do
    @us_states_with_names
  end

  @doc """
  Returns a list of Canadian provinces with their names and codes.

  ## Examples

      iex> get_ca_provinces_with_names()
      [{"Alberta", "AB"}, {"British Columbia", "BC"}, ...]

  """
  def get_ca_provinces_with_names do
    @ca_provinces_with_names
  end

  @doc """
  Returns a list of state/province names and codes for a specific country.

  ## Examples

      iex> get_states_with_names_for_country(:us)
      [{"Alabama", "AL"}, {"Alaska", "AK"}, ...]

      iex> get_states_with_names_for_country(:ca)
      [{"Alberta", "AB"}, {"British Columbia", "BC"}, ...]

      iex> get_states_with_names_for_country("us")
      [{"Alabama", "AL"}, {"Alaska", "AK"}, ...]

  """
  def get_states_with_names_for_country(:us), do: @us_states_with_names
  def get_states_with_names_for_country(:ca), do: @ca_provinces_with_names
  def get_states_with_names_for_country("us"), do: @us_states_with_names
  def get_states_with_names_for_country("ca"), do: @ca_provinces_with_names
  def get_states_with_names_for_country(_), do: []

  @doc """
  Returns a map of country codes to their respective state/province lists with names.

  ## Examples

      iex> get_countries_with_states_and_names()
      %{
        us: [{"Alabama", "AL"}, {"Alaska", "AK"}, ...],
        ca: [{"Alberta", "AB"}, {"British Columbia", "BC"}, ...]
      }

  """
  def get_countries_with_states_and_names do
    %{
      us: @us_states_with_names,
      ca: @ca_provinces_with_names
    }
  end
end
