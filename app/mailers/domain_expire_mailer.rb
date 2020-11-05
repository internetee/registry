class DomainExpireMailer < ApplicationMailer
  attr_accessor :domain, :registrar

  def expired(domain:, registrar:)
    process_mail(domain: domain, registrar: registrar, method_name: __method__.to_s)
  end

  def expired_soft(domain:, registrar:)
    process_mail(domain: domain, registrar: registrar, method_name: __method__.to_s)
  end

  private

  def process_mail(domain:, registrar:, method_name:)
    init(domain, registrar)

    logger.info("Send DomainExpireMailer##{method_name} email for #{domain.name} (##{domain.id})" \
    " to #{recipient(domain).join(', ')}")

    mail(to: recipient(domain), subject: subject(method_name))
  end

  def init(domain, registrar)
    @domain = domain_presenter(domain: domain)
    @registrar = registrar_presenter(registrar: registrar)
  end

  def recipient(domain)
    filter_invalid_emails(emails: domain.primary_contact_emails, domain: @domain)
  end

  def subject(method_name)
    I18n.t("domain_expire_mailer.#{method_name}.subject", domain_name: @domain.name)
  end

  def domain_presenter(domain:)
    DomainPresenter.new(domain: domain, view: view_context)
  end

  def registrar_presenter(registrar:)
    RegistrarPresenter.new(registrar: registrar, view: view_context)
  end

  # Needed because there are invalid emails in the database, which have been imported from legacy app
  def filter_invalid_emails(emails:, domain:)
    emails.select do |email|
      valid = EmailValidator.new(email).valid?

      unless valid
        logger.info("Unable to send DomainExpireMailer#expired email for domain #{domain.name} (##{domain.id})" \
        " to invalid recipient #{email}")
      end

      valid
    end
  end
end
