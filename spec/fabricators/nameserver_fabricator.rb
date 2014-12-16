Fabricator(:nameserver) do
  hostname { "ns.#{Faker::Internet.domain_word}.ee" }
  ipv4 '192.168.1.1'
end
