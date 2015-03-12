Fabricator(:contact) do
  code { "sh#{Faker::Number.number(8)}" }
  auth_info 'password'
  name { sequence(:name) { |i| "#{Faker::Name.name}#{i}" } }
  phone '+372.12345678'
  email Faker::Internet.email
  ident '37605030299'
  ident_type 'priv'
  ident_country_code 'EE'
  address
  registrar { Fabricate(:registrar, name: Faker::Company.name, reg_no: Faker::Company.duns_number) }
  disclosure { Fabricate(:contact_disclosure) }
  # rubocop: disable Style/SymbolProc
  after_validation { |c| c.disable_generate_auth_info! }
  # rubocop: enamble Style/SymbolProc
end
