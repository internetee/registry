Fabricator(:nameserver) do
  hostname { "ns.#{Faker::Internet.domain_word}.ee" }
end
