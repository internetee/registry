FactoryGirl.define do
  factory :dispute do
    sequence(:domain_name) { |n| "test#{n}.com" }
    expire_date Time.zone.parse('05.07.2010')
    password 'test'
    comment 'test'
  end
end
