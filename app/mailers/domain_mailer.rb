class DomainMailer < ApplicationMailer
  def registrant_updated(domain)
    @domain = domain
    return if Rails.env.production? ? false : !TEST_EMAILS.include?(@domain.registrant_email)

    # turn on delivery on specific request only, thus rake tasks does not deliver anything
    return if @domain.deliver_emails != true

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

    mail(to: @old_registrant.email,
         subject: "#{I18n.t(:domain_registrant_update_subject, name: @domain.name)} [#{@domain.name}]")
  end
end
