Fabricator(:nameserver) do
  hostname { sequence(:hostname) { |i| "ns.test#{i}.ee" } }
  ipv4 '192.168.1.1'
end
