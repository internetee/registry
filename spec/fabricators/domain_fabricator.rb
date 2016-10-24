Fabricator(:domain) do
  name { sequence(:name) { |i| "domain#{i}.ee" } }
  valid_to Date.new(2014, 8, 7)
  period 1
  period_unit 'y'
  registrant { Fabricate(:registrant) }
  nameservers(count: 3)
  admin_domain_contacts(count: 1) { Fabricate(:admin_domain_contact) }
  tech_domain_contacts(count: 1) { Fabricate(:tech_domain_contact) }
  registrar { Fabricate(:registrar) }
  auth_info '98oiewslkfkd'
end

Fabricator(:domain_with_dnskeys, from: :domain) do
  after_create { |domain| Fabricate(:dnskey, domain: domain) }
end
