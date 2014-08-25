Fabricator(:contact) do
  phone '+372.12345678'
  email Faker::Internet.email
  ident '37605030299'
  code { "sh#{Faker::Number.number(4)}" }
  ident_type 'op'
  auth_info 'ccds4324pok'
  international_address
end
