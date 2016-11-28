FactoryGirl.define do
  factory :admin_user do
    username 'test'
    password 'test'
    password_confirmation password
    sequence(:email) { |n| "test#{n}@test.com" }
    country_code 'ee'
    roles ['admin']
    identity_code ''
  end
end
