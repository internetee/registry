Fabricator(:contact) do
  name { sequence(:hostname) { |i| "#{Faker::Name.name}#{i}" } }
  phone '+372.12345678'
  email Faker::Internet.email
  ident '37605030299'
  code { "sh#{Faker::Number.number(8)}" }
  ident_type 'op'
  auth_info 'ccds4324pok'
  address
  registrar { Fabricate(:registrar, name: Faker::Company.name, reg_no: Faker::Company.duns_number) }
  disclosure { Fabricate(:contact_disclosure) }
end
