FactoryGirl.define do
  factory :registrar do
    sequence(:name) { |n| "test#{n}" }
    sequence(:code) { |n| "test#{n}" }
    sequence(:reg_no) { |n| "test#{n}" }
    street 'test'
    city 'test'
    state 'test'
    zip 'test'
    email 'test@test.com'
    country_code 'EE'
  end
end
