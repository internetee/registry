class DomainMailer < ApplicationMailer
  def registrant_updated(domain)
    return if Rails.env.production? ? false : !TEST_EMAILS.include?(domain.registrant_email)
    # turn on delivery on specific request only, thus rake tasks does not deliver anything
    return if domain.deliver_emails != true

    @old_registrant = Registrant.find(domain.registrant_id_was)

    @domain = domain
    mail(to: @old_registrant.email, 
         subject: "#{I18n.t(:domain_registrant_update_subject, name: @domain.name)} [#{@domain.name}]")
  end
end
