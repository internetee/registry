FactoryGirl.define do
  factory :reserved_domain do
    sequence(:name) { |n| "test#{n}.com" }
  end
end
