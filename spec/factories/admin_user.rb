FactoryBot.define do
  factory :admin_user do
    username 'test'
    sequence(:email) { |n| "test#{n}@test.com" }
    password 'a' * AdminUser.min_password_length
    password_confirmation { password }
    country_code 'de'
    roles ['admin']
  end
end
