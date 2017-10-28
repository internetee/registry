FactoryGirl.define do
  factory :reserved_domain do
    sequence(:name) { |i| "domain#{i}.ee" }
  end
end
