FactoryGirl.define do
  factory :api_user do
    sequence(:username) { |n| "test#{n}" }
    password 'a' * 6
    roles ['super']
    registrar
  end
end
