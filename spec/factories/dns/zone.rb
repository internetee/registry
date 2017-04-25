FactoryGirl.define do
  factory :zone, class: DNS::Zone do
    sequence(:origin) { |n| "test#{n}" }
    ttl 1
    refresh 1
    add_attribute :retry, 1
    expire 1
    minimum_ttl 1
    email 'test@test.test'
    master_nameserver 'test.test'
  end
end
