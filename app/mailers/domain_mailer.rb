class DomainMailer < ApplicationMailer
  def registrant_updated(domain)
    @domain = domain
    return if Rails.env.production? ? false : !TEST_EMAILS.include?(@domain.registrant_email)
    # turn on delivery on specific request only, thus rake tasks does not deliver anything
    return if @domain.deliver_emails != true
    if @domain.registrant_verification_token.blank?
      logger.warn "EMAIL DID NOT DELIVERED: registrant_verification_token is missing for #{@domain.name}"
      return
    end

    @old_registrant = Registrant.find(@domain.registrant_id_was)
    @verification_url = "#{ENV['registrant_url']}/etc/"

    mail(to: @old_registrant.email,
         subject: "#{I18n.t(:domain_registrant_update_subject, name: @domain.name)} [#{@domain.name}]")
  end
end
