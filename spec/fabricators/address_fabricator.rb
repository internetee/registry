Fabricator(:address) do
  city    Faker::Address.city
  street  Faker::Address.street_name
  street2 Faker::Address.street_name
  zip     Faker::Address.zip
end
