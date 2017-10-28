FactoryBot.define do
  factory :registrant_verification do
    sequence(:domain_name) { |i| "domain#{i}.ee" }
    domain
    verification_token '123'
    action 'confirmed'
    action_type 'registrant_change'
  end
end
