Fabricator(:contact) do
  name  Faker::Name.name
  phone '+372.12345678'
  email Faker::Internet.email
  ident '37605030299'  
end
