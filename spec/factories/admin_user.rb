FactoryGirl.define do
  factory :admin_user do
    username 'test'
    email 'test@test.com'
    password 'a' * AdminUser.min_password_length
    password_confirmation { password }
    country_code 'de'
    roles ['admin']
  end
end
