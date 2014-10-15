Fabricator(:domain) do
  name { "#{Faker::Internet.domain_word}.ee" }
  valid_to Date.new(2014, 8, 7)
  period 1
  period_unit 'y'
  owner_contact(fabricator: :contact)
  nameservers(count: 3)
  admin_contacts(count: 1) { Fabricate(:contact) }
  registrar
  auth_info '98oiewslkfkd'
  dnskeys(count: 1)
end
