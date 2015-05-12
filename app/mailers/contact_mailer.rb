class ContactMailer < ApplicationMailer
  def email_updated(contact)
    unless Rails.env.production?
      return unless TEST_EMAILS.include?(contact.email) || TEST_EMAILS.include?(contact.email_was)
    end

    # turn on delivery on specific request only, thus rake tasks does not deliver anything
    return if contact.deliver_emails != true

    @contact = contact
    mail(to: [@contact.email, @contact.email_was], subject: I18n.t(:contact_email_update_subject))
  end
end
