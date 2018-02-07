FactoryBot.define do
  factory :epp_session do
    sequence(:session_id) { |n| "test#{n}" }
    registrar
    association :user, factory: :api_user
  end
end
