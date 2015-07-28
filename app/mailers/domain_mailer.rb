class DomainMailer < ApplicationMailer
  def pending_update_request_for_old_registrant(domain)
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
         subject: "#{I18n.t(:pending_update_request_for_old_registrant_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_update_notification_for_new_registrant(domain)
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
         subject: "#{I18n.t(:pending_update_notification_for_new_registrant_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def registrant_updated_notification_for_new_registrant(domain)
    @domain = domain
    return if delivery_off?(@domain)

    return if whitelist_blocked?(@domain.registrant_email)
    mail(to: @domain.registrant_email,
         subject: "#{I18n.t(:registrant_updated_notification_for_new_registrant_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def registrant_updated_notification_for_old_registrant(domain)
    @domain = domain
    return if delivery_off?(@domain)
    
    @old_registrant_email = domain.registrant_email # Nb! before applying pending updates

    return if whitelist_blocked?(@old_registrant_email)
    mail(to: @old_registrant_email,
         subject: "#{I18n.t(:registrant_updated_notification_for_old_registrant_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_update_rejected_notification_for_new_registrant(domain)
    @domain = domain
    # no delivery off control, driggered by que, no epp request

    @new_registrant_email = @domain.pending_json[:new_registrant_email] 
    @new_registrant_name  = @domain.pending_json[:new_registrant_name] 

    return if whitelist_blocked?(@new_registrant_email)
    mail(to: @new_registrant_email,
         subject: "#{I18n.t(:pending_update_rejected_notification_for_new_registrant_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end

  def pending_update_expired_notification_for_new_registrant(domain)
    @domain = domain
    # no delivery off control, driggered by cron, no epp request

    @new_registrant_email = @domain.pending_json[:new_registrant_email] 
    @new_registrant_name  = @domain.pending_json[:new_registrant_name] 

    return if whitelist_blocked?(@new_registrant_email)
    if @new_registrant_email.blank?
      logger.info "EMAIL NOT DELIVERED: no registrant email [pending_update_expired_notification_for_new_registrant]"
      return
    end
    mail(to: @new_registrant_email,
         subject: "#{I18n.t(:pending_update_expired_notification_for_new_registrant_subject, 
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

  def pending_delete_rejected_notification(domain)
    @domain = domain
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
    mail(to: @domain.registrant.email,
         subject: "#{I18n.t(:pending_delete_rejected_notification_subject, 
         name: @domain.name)} [#{@domain.name}]")
  end
end
