class DomainExpireMailer < ApplicationMailer
  attr_accessor :domain, :registrar, :email

  def expired(domain:, registrar:, email:)
    process_mail(domain: domain, registrar: registrar, email: email, method_name: __method__.to_s)
  end

  def expired_soft(domain:, registrar:, email:)
    process_mail(domain: domain, registrar: registrar, email: email, method_name: __method__.to_s)
  end

  def notify_soft_violation(domain:, registrar:, email:)
    process_mail(domain: domain, registrar: registrar, email: email, method_name: __method__.to_s, multiyears_expiration: true)
  end

  private

  def process_mail(domain:, registrar:, email:, method_name:, multiyears_expiration: false)
    init(domain, registrar)

    if multiyears_expiration
      logger.info("Send DomainExpireMailer##{method_name} email for #{domain.name} (##{domain.id})" \
      " to #{email} because of multiyears expiration")
    else
      logger.info("Send DomainExpireMailer##{method_name} email for #{domain.name} (##{domain.id})" \
      " to #{email}")
    end

    mail(to: email, subject: subject(method_name))
  end

  def init(domain, registrar)
    @domain = domain_presenter(domain: domain)
    @registrar = registrar_presenter(registrar: registrar)
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
end
