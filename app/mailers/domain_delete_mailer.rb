class DomainDeleteMailer < ApplicationMailer
  def confirm(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @confirm_url = confirm_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: registrant.email, subject: subject)
  end

  def forced(domain:, registrar:, registrant:, template_name:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)

    @force_delete_set_date = Time.zone.now
    @redemption_grace_period = Setting.redemption_grace_period

    mail(to: domain.primary_contact_emails,
         template_path: 'mailers/domain_delete_mailer/forced',
         template_name: template_name)
  end

  private

  def confirm_url(domain)
    registrant_domain_delete_confirm_url(domain, token: domain.registrant_verification_token)
  end
end
