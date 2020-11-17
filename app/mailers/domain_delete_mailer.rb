class DomainDeleteMailer < ApplicationMailer
  def confirmation_request(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @confirmation_url = confirmation_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: registrant.email, subject: subject)
  end

  def accepted(domain)
    @domain = domain

    subject = default_i18n_subject(domain: domain.name)
    mail(to: domain.registrant.email, subject: subject)
  end

  def rejected(domain)
    @domain = domain

    subject = default_i18n_subject(domain: domain.name)
    mail(to: domain.registrant.email, subject: subject)
  end

  def expired(domain)
    @domain = domain

    subject = default_i18n_subject(domain: domain.name)
    mail(to: domain.registrant.email, subject: subject)
  end

  def forced(domain:, registrar:, registrant:, template_name:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)

    @redemption_grace_period = Setting.redemption_grace_period
    @expire_warning_period = Setting.expire_warning_period
    @delete_period_length = @redemption_grace_period + @expire_warning_period

    subject = default_i18n_subject(domain_name: domain.name)
    mail(from: forced_email_from,
         to: domain.force_delete_contact_emails,
         subject: subject,
         template_path: 'mailers/domain_delete_mailer/forced',
         template_name: template_name)
  end

  private

  def confirmation_url(domain)
    registrant_domain_delete_confirm_url(domain, token: domain.registrant_verification_token)
  end

  def forced_email_from
    ENV['action_mailer_force_delete_from'] || self.class.default[:from]
  end
end
