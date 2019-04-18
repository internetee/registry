class ContactMailer < ApplicationMailer
  helper_method :address_processing

  def email_changed(contact:, old_email:)
    @contact = contact
    @old_email = old_email

    subject = default_i18n_subject(contact_code: contact.code)
    mail(to: contact.email, bcc: old_email, subject: subject)
  end

  private

  def address_processing
    Contact.address_processing?
  end
end