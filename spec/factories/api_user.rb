FactoryGirl.define do
  factory :api_user do
    sequence(:username) { |n| "test#{n}" }
    password 'a' * 6
    roles ['super']
    registrar

    factory :api_user_epp do
      roles %w(epp static_registrant)
    end
  end
end
