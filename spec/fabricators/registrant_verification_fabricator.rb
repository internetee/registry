Fabricator(:registrant_verification) do
  domain_name { sequence(:name) { |i| "domain#{i}.ee" } }
  domain(fabricate: :domain)
  verification_token '123'
  action 'confirmed'
  action_type 'registrant_change'
end
