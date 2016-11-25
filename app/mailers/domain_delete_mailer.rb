class DomainDeleteMailer < ApplicationMailer
  def confirm(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @confirm_url = confirm_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: registrant.email, subject: subject)
  end

  def forced(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)

    mail(to: domain.primary_contact_emails)
  end

  private

  def confirm_url(domain)
    registrant_domain_delete_confirm_url(domain, token: domain.registrant_verification_token)
  end
end
