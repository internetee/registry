Fabricator(:registrant_verification) do
  domain_name { sequence(:name) { |i| "domain#{i}.ee" } }
  verification_token '123'
end
