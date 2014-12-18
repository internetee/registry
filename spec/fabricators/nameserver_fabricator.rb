Fabricator(:nameserver) do
  hostname { sequence(:hostname) { |i| "ns.#{Faker::Internet.domain_word}#{i}.ee" } }
  ipv4 '192.168.1.1'
end
