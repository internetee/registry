class ContactInformMailer < ApplicationMailer
  helper_method :address_processing

  def notify_dnssec(contact:, domain:)
    @contact = contact
    @domain = domain

    subject = "Domeeni #{@domain.name} DNSSEC kirjed ei ole korrektsed / The DNSKEY records of the domain #{@domain.name} are invalid"

    mail(to: contact.email, subject: subject)
  end

  def notify_nameserver(contact:, domain:, nameserver:)
    @contact = contact
    @domain = domain
    @nameserver = nameserver

    subject = "Domeeni #{@domain.name} nimeserveri kirjed ei ole korrektsed / The host records of the domain #{@domain.name} are invalid"
    mail(to: contact.email, subject: subject)
  end

  private

  def address_processing
    Contact.address_processing?
  end
end
