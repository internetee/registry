Fabricator(:country) do
  iso  Faker::Address.state_abbr
  name Faker::Address.country
end
