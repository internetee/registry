FactoryGirl.define do
  factory :api_user do
    sequence(:username) { |n| "test#{n}" }
    password 'a' * ApiUser.min_password_length
    roles ['super']
    registrar

    factory :api_user_epp do
      roles %w(epp static_registrant)
    end
  end
end
