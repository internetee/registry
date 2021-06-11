namespace :collect_invalid_contacts do
  desc 'Starts collect invalid validation contacts'
  task all_domains: :environment do
    prepare_csv_file

    Contact.all.each do |contact|
      result = Truemail.validate(contact.email, with: :mx)
      if !result.result.success && !validate_puny_code(contact.email)
        collect_data_for_csv(contact, result.result)
      end
    end
  end
end

def find_related_domains(contact)
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

def collect_data_for_csv(contact, result)
  domains = find_related_domains(contact)

  CSV.open('invalid_emails.csv', 'a') do |csv|
    domains.each do |domain|
      attrs = []
      attrs.push(domain.name)
      attrs.push(contact.email)
      attrs.push(result.errors)

      csv << attrs
    end
  end
end

def prepare_csv_file
  headers = %w[
    contact
    domain
    error
  ]
  csv = CSV.open('invalid_emails.csv', 'w')
  csv << headers
end

def validate_puny_code(email)
  email.include?('xn--')
end
