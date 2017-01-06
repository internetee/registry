class DomainMailer < ApplicationMailer
  include Que::Mailer

  def registrant_updated_notification_for_new_registrant(domain_id, old_registrant_id, new_registrant_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)

    @old_registrant = Registrant.find(old_registrant_id)
    @new_registrant = Registrant.find(new_registrant_id)
    @address_processing = Contact.address_processing?

    return if whitelist_blocked?(@new_registrant.email)
    mail(to: format(@new_registrant.email),
         subject: "#{I18n.t(:registrant_updated_notification_for_new_registrant_subject,
                            name: @domain.name)} [#{@domain.name}]")
  end


  def registrant_updated_notification_for_old_registrant(domain_id, old_registrant_id, new_registrant_id, should_deliver)
    @domain = Domain.find_by(id: domain_id)
    return unless @domain
    return if delivery_off?(@domain, should_deliver)

    @old_registrant = Registrant.find(old_registrant_id)
    @new_registrant = Registrant.find(new_registrant_id)
    @address_processing = Contact.address_processing?

    return if whitelist_blocked?(@old_registrant.email)
    mail(to: format(@old_registrant.email),
         subject: "#{I18n.t(:registrant_updated_notification_for_old_registrant_subject,
                            name: @domain.name)} [#{@domain.name}]")
  end

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

  private
  # app/models/DomainMailModel provides the data for mail that can be composed_from
  # which ensures that values of objects are captured when they are valid, not later when this method is executed
  def compose_from(params)
    @params = params
    return if delivery_off?(params, params[:deliver_emails])
    return if whitelist_blocked?(params[:recipient])
    params[:errors].map do |error|
      logger.warn error
      return
    end
    mail(to: params[:recipient], subject: params[:subject])
  end
end
