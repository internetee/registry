HEADERS = %w[domain id name code registrar].freeze

namespace :contacts do
  desc 'Starts collect invalid validation contacts'
  task scan_org: :environment do
    csv = CSV.open('invalid_business_contacts.csv', 'w')
    csv << HEADERS

    Contact.where(ident_type: 'org').find_in_batches do |contact_group|
      contact_group.each do |contact|
        next if checking_contacts(contact)

        domains = domain_filter(contact)
        domains.each do |domain|
          registrar = Registrar.find_by(id: domain.registrar_id)
          csv << [domain.name, contact.id, contact.name, contact.ident, registrar.name]
        end
      end
    end
  end
end

def checking_contacts(contact)
  return true unless contact.ident_country_code == 'EE'

  c = BusinessRegistryContact.find_by(registry_code: contact.ident)
  return false if c.nil? || c.status == 'N'

  true
end

def domain_filter(contact)
  domains = searching_domains(contact)
  domains.reject! { |dom| dom.statuses.include? DomainStatus::FORCE_DELETE }
  domains
end

def searching_domains(contact)
  registrant_domains = Domain.where(registrant_id: contact.id)

  tech_domains = collect_tech_domains(contact)

  tech_domains | registrant_domains
end

def collect_tech_domains(contact)
  tech_domains = []

  tech_contacts = TechDomainContact.where(contact_id: contact.id)
  tech_contacts.each do |c|
    tech_domains << Domain.find(c.domain_id)
  end

  tech_domains
end
