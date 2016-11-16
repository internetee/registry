class DomainExpireMailer < ApplicationMailer
  def expired(domain:, registrar:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: domain.primary_contact_emails, subject: subject)
  end
end
