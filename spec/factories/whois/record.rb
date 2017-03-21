FactoryGirl.define do
  factory :whois_record, class: Whois::Record do
    sequence(:domain_name) { |n| "test#{n}.com" }
    body 'test'
    json({ test: 'test' })
  end
end
