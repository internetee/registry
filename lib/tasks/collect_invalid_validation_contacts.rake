namespace :collect_invalid_contacts do
  desc 'Starts collect invalid business contacts'
  task all_domains: :environment do
    prepare_csv_file

    Contact.all.each do |contact|
      email = convert_to_unicode(contact.email)
      result = Truemail.validate(email, with: :mx)

      collect_data_for_csv(contact, result.result) unless result.result.success
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
  domains.reject! { |dom| dom.statuses.include? DomainStatus::FORCE_DELETE }

  CSV.open('invalid_emails.csv', 'a') do |csv|
    domains.each do |domain|
      attrs = []
      attrs.push(domain.name, contact.email, result.errors)

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

def convert_to_unicode(email)
  original_domain = Mail::Address.new(email).domain
  decoded_domain = SimpleIDN.to_unicode(original_domain)

  original_local = Mail::Address.new(email).local
  decoded_local = SimpleIDN.to_unicode(original_local)

  "#{decoded_local}@#{decoded_domain}"
end
