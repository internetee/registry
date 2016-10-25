Fabricator(:contact) do
  registrar { Fabricate(:registrar) }
  code { sequence(:code) { |i| "1234#{i}#{rand(1000)}" } }
  auth_info 'password'
  name 'test name'
  phone '+372.12345678'
  email { sequence(:email) { |i| "test#{i}@test.com" } }
  street 'Short street 11'
  city 'Tallinn'
  zip '11111'
  country_code 'EE'
  ident '37605030299'
  ident_type 'priv'
  ident_country_code 'EE'
  # rubocop: disable Style/SymbolProc
  after_validation { |c| c.disable_generate_auth_info! }
  # rubocop: enamble Style/SymbolProc
end
