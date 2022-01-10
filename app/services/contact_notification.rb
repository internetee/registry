module ContactNotification
  extend self

  def notify_registrar(domain:, text:)
    domain.registrar.notifications.create(text: text)
  end

  def notify_tech_contact(domain:, text:)
    # text = "DNSKEYS for #{domain.name} are invalid!"
    domain.tech_contacts.each do |tech|
      contact = Contact.find(tech.id)

      ContactInformMailer.notify(contact: contact, domain: domain, subject: text).deliver_now
    end
  end
end
