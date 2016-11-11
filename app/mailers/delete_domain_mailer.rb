class DeleteDomainMailer < ApplicationMailer
  include Que::Mailer

  def pending(domain:, old_registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: domain.registrar, view: view_context)
    @verification_url = verification_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: old_registrant.email, subject: subject)
  end

  private

  def verification_url(domain)
    registrant_domain_delete_confirm_url(domain, token: domain.registrant_verification_token)
  end
end
