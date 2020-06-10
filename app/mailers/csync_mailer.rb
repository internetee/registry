class CsyncMailer < ApplicationMailer
  helper_method :address_processing

  def dnssec_updated(domain:)
    emails = contact_emails(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: emails, subject: subject)
  end

  def dnssec_deleted(domain:)
    emails = contact_emails(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: emails, subject: subject)
  end

  private

  def contact_emails(domain)
    (domain.contacts.map(&:email) << domain.registrant.email).uniq
  end
end
