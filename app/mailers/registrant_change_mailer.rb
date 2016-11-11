class RegistrantChangeMailer < ApplicationMailer
  include Que::Mailer

  def confirmation(domain:, registrant:)
    @domain = DomainPresenter.new(domain: domain, view: view_context)
    @registrar = RegistrarPresenter.new(registrar: domain.registrar, view: view_context)
    @registrant = RegistrantPresenter.new(registrant: registrant, view: view_context)
    @verification_url = confirm_url(domain)

    subject = default_i18n_subject(domain_name: domain.name)
    mail(to: registrant.email, subject: subject)
  end

  def pending_update_notification_for_new_registrant(params)
    compose_from(params)
  end

  def registrant_updated_notification_for_old_registrant(domain_id, old_registrant_id, new_registrant_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)

    @old_registrant = Registrant.find(old_registrant_id)
    @new_registrant = Registrant.find(new_registrant_id)

    return if whitelist_blocked?(@old_registrant.email)
    mail(to: format(@old_registrant.email),
         subject: "#{I18n.t(:registrant_updated_notification_for_old_registrant_subject,
                            name: @domain.name)} [#{@domain.name}]")
  end

  def pending_update_rejected_notification_for_new_registrant(params)
    compose_from(params)
  end

  def pending_update_expired_notification_for_new_registrant(params)
    compose_from(params)
  end

  private

  def confirm_url(domain)
    registrant_domain_update_confirm_url(domain, token: domain.registrant_verification_token)
  end
end
