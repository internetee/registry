class DomainMailer < ApplicationMailer
  include Que::Mailer

  def pending_delete_rejected_notification(domain_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)
    # no delivery off control, driggered by que, no epp request

    if @domain.registrant_verification_token.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{@domain.name}"
      return
    end

    if @domain.registrant_verification_asked_at.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{@domain.name}"
      return
    end

    return if whitelist_blocked?(@domain.registrant.email)
    mail(to: format(@domain.registrant.email),
         subject: "#{I18n.t(:pending_delete_rejected_notification_subject,
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_delete_expired_notification(domain_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)
    # no delivery off control, driggered by cron, no epp request

    return if whitelist_blocked?(@domain.registrant.email)
    mail(to: format(@domain.registrant.email),
         subject: "#{I18n.t(:pending_delete_expired_notification_subject,
         name: @domain.name)} [#{@domain.name}]")
  end

  def delete_confirmation(domain_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)

    return if whitelist_blocked?(@domain.registrant.email)
    mail(to: format(@domain.registrant.email),
         subject: "#{I18n.t(:delete_confirmation_subject,
         name: @domain.name)} [#{@domain.name}]")
  end
end