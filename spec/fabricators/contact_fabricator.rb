Fabricator(:contact) do
  name  Faker::Name.name
  phone '+372.12345678'
  email Faker::Internet.email
  ident '37605030299'  
  code 'sh8913'
  ident_type 'op'
  addresses(count: 2)
end
