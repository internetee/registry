FactoryBot.define do
  factory :nameserver do
    sequence(:hostname) { |n| "ns.test#{n}.ee" }
    ipv4 '192.168.1.1'
    domain
  end
end
