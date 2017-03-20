FactoryGirl.define do
  factory :blocked_domain do
    sequence(:name) { |n| "test#{n}.com" }
  end
end
