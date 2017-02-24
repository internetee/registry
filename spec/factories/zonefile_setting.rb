FactoryGirl.define do
  factory :zonefile_setting do
    sequence(:origin) { |n| "test#{n}" }
    ttl 1
    refresh 1
    add_attribute(:retry) { 1 }
    expire 1
    minimum_ttl 1
    email 'test@test.com'
    master_nameserver 'test.com'
  end
end
