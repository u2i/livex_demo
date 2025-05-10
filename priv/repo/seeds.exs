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
alias LivexDemo.Demo.Location

# Clear existing locations
Repo.delete_all(Location)

# Define US states (two characters, capitalized)
us_states = [
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
]

# Define Canadian provinces (two characters, capitalized)
ca_provinces = [
  "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"
]

# Generate 300 random locations
locations_count = 300
locations = Enum.map(1..locations_count, fn _ ->
  # Randomly choose country (70% US, 30% Canada)
  country = if :rand.uniform(10) <= 7, do: "us", else: "ca"
  
  # Select appropriate state/province based on country
  state = case country do
    "us" -> Enum.random(us_states)
    "ca" -> Enum.random(ca_provinces)
  end
  
  # Generate location data
  %{
    name: "#{Faker.Company.name()} #{Enum.random(["Office", "Branch", "Center", "Hub", "Location", "Headquarters"])}",
    street: "#{Faker.Address.building_number()} #{Faker.Address.street_name()}",
    city: Faker.Address.city(),
    state: state,
    zip: if(country == "us", do: Faker.Address.zip_code(), else: Faker.Address.postcode()),
    country: country,
    description: Faker.Lorem.paragraph(1..3)
  }
end)

# Insert all locations
{time, _} = :timer.tc(fn ->
  Enum.each(locations, fn location_data ->
    %Location{}
    |> Location.changeset(location_data)
    |> Repo.insert!()
  end)
end)

IO.puts("Inserted #{length(locations)} locations in #{time / 1_000_000} seconds")
