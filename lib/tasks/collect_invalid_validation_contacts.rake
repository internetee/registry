namespace :collect_invalid_contacts do
  desc 'Starts collect invalid validation contacts'
  task all_domains: :environment do
    Contact.all.each do |contact|
      result = Truemail.validate(contact.email, with: :mx)
      unless result.result.success
        collect_data_for_csv(contact, result.result)
      end
    end
  end
end

def find_related_domains(contact)
  Domain.where(id: contact.id)
end

def collect_data_for_csv(contact, result)
  domains = find_related_domains(contact)

  headers = %w[
    contact
    domain
    error
  ]

  CSV.open('invalid_email.csv', 'w') do |csv|
    csv << headers

    domains.each do |domain|
      attrs = []
      attrs.push(domain)
      attrs.push(contact.email)
      attrs.push(result.errors)

      csv << attrs
    end
  end
end