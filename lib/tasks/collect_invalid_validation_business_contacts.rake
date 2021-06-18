HEADERS = %w[domain id name code registrar].freeze

namespace :contacts do
  desc 'Starts collect invalid validation contacts'
  task scan_org: :environment do
    contacts = []

    Contact.where(ident_type: 'org').each do |contact|
      contacts << contact unless checking_contacts(contact)
    end

    contacts.select! { |c| c.ident_country_code == 'EE' }
    magic_with_contacts(contacts)
  end
end

def checking_contacts(contact)
  c = BusinessRegistryContact.find_by(registry_code: contact.ident)
  return false if c.nil? || c.status == 'N'

  true
end

def magic_with_contacts(contacts)
  CSV.open('invalid_business_contacts.csv', 'w') do |csv|
    csv << HEADERS
    contacts.each do |contact|
      domains = domain_filter(contact)
      domains.each do |domain|
        registrar = Registrar.find_by(id: domain.registrar_id)
        csv << [domain.name, contact.id, contact.name, contact.ident, registrar.name]
      end
    end
  end
end

def domain_filter(contact)
  domains = searching_domains(contact)
  domains.reject! { |dom| dom.statuses.include? DomainStatus::FORCE_DELETE }
  domains
end

def searching_domains(contact)
  registrant_domains = Domain.where(registrant_id: contact.id)

  tech_domains = collect_tech_domains(contact)
  admin_domains = collect_admin_domains(contact)

  tech_domains | admin_domains | registrant_domains
end

def collect_admin_domains(contact)
  admin_domains = []

  admin_contacts = AdminDomainContact.where(contact_id: contact.id)
  admin_contacts.each do |c|
    admin_domains << Domain.find(c.domain_id)
  end

  admin_domains
end

def collect_tech_domains(contact)
  tech_domains = []

  tech_contacts = TechDomainContact.where(contact_id: contact.id)
  tech_contacts.each do |c|
    tech_domains << Domain.find(c.domain_id)
  end

  tech_domains
end
