FactoryGirl.define do
  factory :dispute do
    expire_date Time.zone.today
    password 'test'
    comment 'test'
    domain
  end
end
