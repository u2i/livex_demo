# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LivexDemo.Repo.insert!(%LivexDemo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias LivexDemo.Repo
alias LivexDemo.Demo
alias LivexDemo.Demo.Location

# Clear existing locations
Repo.delete_all(Location)

# Get countries and their states/provinces from the domain API
countries_with_states_and_names = Demo.get_countries_with_states_and_names()
countries = Map.keys(countries_with_states_and_names)

# Generate 300 random locations
locations_count = 300

locations =
  Enum.map(1..locations_count, fn _ ->
    # Randomly choose country (70% US, 30% Canada)
    country_atom = if :rand.uniform(10) <= 7, do: :us, else: :ca
    country_str = Atom.to_string(country_atom)

    # Select appropriate state/province based on country
    state = Enum.random(Demo.get_states_for_country(country_atom))

    # Generate location data
    %{
      name:
        "#{Faker.Company.name()} #{Enum.random(["Office", "Branch", "Center", "Hub", "Location", "Headquarters"])}",
      street: "#{Faker.Address.building_number()} #{Faker.Address.street_name()}",
      city: Faker.Address.city(),
      state: state,
      zip: if(country_atom == :us, do: Faker.Address.zip_code(), else: Faker.Address.postcode()),
      # Store as string in the database
      country: country_str,
      description: Faker.Lorem.paragraph(1..3)
    }
  end)

# Insert all locations
{time, _} =
  :timer.tc(fn ->
    Enum.each(locations, fn location_data ->
      case Demo.create_location(location_data) do
        {:ok, _location} ->
          :ok

        {:error, changeset} ->
          IO.puts("Error creating location: #{inspect(changeset.errors)}")
      end
    end)
  end)

IO.puts("Inserted #{length(locations)} locations in #{time / 1_000_000} seconds")
