Fabricator(:domain_contact) do
  contact { Fabricate(:contact) }
  type 'TechDomainContact'
end

Fabricator(:tech_domain_contact, from: :domain_contact) do
  type 'TechDomainContact'
end

Fabricator(:admin_domain_contact, from: :domain_contact) do
  type 'AdminDomainContact'
end
