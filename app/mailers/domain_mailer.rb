class DomainMailer < ApplicationMailer
  def pending_update_old_registrant_request(domain)
    @domain = domain
    return if delivery_off?(@domain)

    if @domain.registrant_verification_token.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{@domain.name}"
      return
    end

    if @domain.registrant_verification_asked_at.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{@domain.name}"
      return
    end

    @old_registrant = Registrant.find(@domain.registrant_id_was)

    confirm_path = "#{ENV['registrant_url']}/registrant/domain_update_confirms"
    @verification_url = "#{confirm_path}/#{@domain.id}?token=#{@domain.registrant_verification_token}"

    return if whitelist_blocked?(@old_registrant.email)
    mail(to: @old_registrant.email,
         subject: "#{I18n.t(:pending_update_old_registrant_request_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_update_new_registrant_notification(domain)
    @domain = domain
    return if delivery_off?(@domain)

    if @domain.registrant_verification_token.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{@domain.name}"
      return
    end

    if @domain.registrant_verification_asked_at.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{@domain.name}"
      return
    end

    @new_registrant = @domain.registrant # NB! new registrant at this point
    @old_registrant = Registrant.find(@domain.registrant_id_was)

    return if whitelist_blocked?(@new_registrant.email)
    mail(to: @new_registrant.email,
         subject: "#{I18n.t(:pending_update_new_registrant_notification_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def registrant_updated(domain)
    @domain = domain
    return if delivery_off?(@domain)

    return if whitelist_blocked?(@domain.registrant_email)
    mail(to: @domain.registrant_email,
         subject: "#{I18n.t(:domain_registrant_updated, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_deleted(domain)
    @domain = domain
    return if delivery_off?(@domain)

    if @domain.registrant_verification_token.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{@domain.name}"
      return
    end

    if @domain.registrant_verification_asked_at.blank?
      logger.warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{@domain.name}"
      return
    end

    @old_registrant = Registrant.find(@domain.registrant_id_was)

    confirm_path = "#{ENV['registrant_url']}/registrant/domain_delete_confirms"
    @verification_url = "#{confirm_path}/#{@domain.id}?token=#{@domain.registrant_verification_token}"

    return if whitelist_blocked?(@old_registrant.email)
    mail(to: @old_registrant.email,
         subject: "#{I18n.t(:domain_pending_deleted_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end
end
