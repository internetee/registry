module ContactNotification
  extend self

  def notify_registrar(domain:, text:)
    domain.registrar.notifications.create(text: text)
  end

  def notify_tech_contact(domain:, reason: nil)
    case reason
    when 'dnssec'
      domain.tech_contacts.each do |tech|
        contact = Contact.find(tech.id)

        ContactInformMailer.notify_dnssec(contact: contact, domain: domain).deliver_now
      end
    when 'nameserver'
      domain.tech_contacts.each do |tech|
        contact = Contact.find(tech.id)

        ContactInformMailer.notify_nameserver(contact: contact, domain: domain).deliver_now
      end
    end
  end
end
