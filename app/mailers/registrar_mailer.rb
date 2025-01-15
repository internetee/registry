class RegistrarMailer < ApplicationMailer
  helper ApplicationHelper

  def contact_verified(email:, contact:, poi:)
    @contact = contact
    subject = default_i18n_subject(contact_code: contact.code)
    attachments['proof_of_identity.pdf'] = poi
    mail(to: email, subject: subject)
  end
end
