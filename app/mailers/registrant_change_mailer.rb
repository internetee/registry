class RegistrantChangeMailer < ApplicationMailer
  include Que::Mailer

  def confirm(domain:, registrar:, current_registrant:, new_registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @new_registrant = RegistrantPresenter.new(registrant: new_registrant, view: view_context)
    @confirm_url = confirm_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: current_registrant.email, subject: subject)
  end

  def notice(domain:, registrar:, current_registrant:, new_registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @current_registrant = RegistrantPresenter.new(registrant: current_registrant, view: view_context)
    @new_registrant = RegistrantPresenter.new(registrant: new_registrant, view: view_context)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: new_registrant.email, subject: subject)
  end

  def rejected(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: domain.new_registrant_email, subject: subject)
  end

  def expired(domain:, registrar:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: domain.new_registrant_email, subject: subject)
  end

  private

  def confirm_url(domain)
    registrant_domain_update_confirm_url(domain, token: domain.registrant_verification_token)
  end
end
