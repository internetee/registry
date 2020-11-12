class RegistrantChangeMailer < ApplicationMailer
  helper_method :address_processing

  def confirmation_request(domain:, registrar:, current_registrant:, new_registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @new_registrant = RegistrantPresenter.new(registrant: new_registrant, view: view_context)
    @confirmation_url = registrant_confirm_url(domain: domain, method: 'change')

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: current_registrant.email, subject: subject)
  end

  def notification(domain:, registrar:, current_registrant:, new_registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: registrar, view: view_context)
    @current_registrant = RegistrantPresenter.new(registrant: current_registrant, view: view_context)
    @new_registrant = RegistrantPresenter.new(registrant: new_registrant, view: view_context)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: new_registrant.email, subject: subject)
  end

  def accepted(domain:, old_registrant:)
    @domain = domain
    recipients = [domain.registrant.email, old_registrant.email]
    subject = default_i18n_subject(domain_name: domain.name)

    mail(to: recipients, subject: subject)
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

  def address_processing
    Contact.address_processing?
  end
end
