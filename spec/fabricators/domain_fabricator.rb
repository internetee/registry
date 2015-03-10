Fabricator(:domain) do
  name { sequence(:name) { |i| "fabricate_name#{i}.ee" } }
  valid_to Date.new(2014, 8, 7)
  period 1
  period_unit 'y'
  owner_contact(fabricator: :contact)
  nameservers(count: 3)
  domain_contacts(count: 1) { Fabricate(:domain_contact, contact_type: 'admin') }
  registrar
  auth_info '98oiewslkfkd'
end

Fabricator(:domain_with_dnskeys, from: :domain) do
  dnskeys(count: 1)
end
