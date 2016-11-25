class DomainExpireMailer < ApplicationMailer
  def expired(domain:, registrar:)
    @domain = domain_presenter(domain: domain)
    @registrar = registrar_presenter(registrar: registrar)

    recipient = filter_invalid_emails(emails: domain.primary_contact_emails, domain: domain)
    subject = default_i18n_subject(domain_name: domain.name)

    logger.info("Send DomainExpireMailer#expired email for domain #{domain.name} (##{domain.id})" \
    " to #{domain.primary_contact_emails.join(', ')}")

    mail(to: recipient, subject: subject)
  end

  private

  def domain_presenter(domain:)
    DomainPresenter.new(domain: domain, view: view_context)
  end

  def registrar_presenter(registrar:)
    RegistrarPresenter.new(registrar: registrar, view: view_context)
  end

  # Needed because there are invalid emails in the database, which have been imported from legacy app
  def filter_invalid_emails(emails:, domain:)
    emails.keep_if do |email|
      valid = EmailValidator.new(email).valid?

      unless valid
        logger.info("Unable to send DomainExpireMailer#expired email for domain #{domain.name} (##{domain.id})" \
        " to invalid recipient #{email}")
      end

      valid
    end
  end
end
