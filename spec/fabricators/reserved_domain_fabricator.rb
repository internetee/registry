Fabricator(:reserved_domain) do
  name { sequence(:name) { |i| "domain#{i}.ee" } }
end
