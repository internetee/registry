class DomainMailer < ApplicationMailer
  def registrant_pending_updated(domain)
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
         subject: "#{I18n.t(:domain_registrant_pending_updated_subject, name: @domain.name)} [#{@domain.name}]")
  end

  def registrant_updated(domain)
    @domain = domain
    return if delivery_off?(@domain)

    return if whitelist_blocked?(@domain.registrant_email)
    mail(to: @domain.registrant_email,
         subject: "#{I18n.t(:domain_registrant_updated, name: @domain.name)} [#{@domain.name}]")
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
         subject: "#{I18n.t(:domain_pending_deleted_subject, name: @domain.name)} [#{@domain.name}]")
  end
end
