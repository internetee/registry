class RegistrarMailer < ApplicationMailer
  helper ApplicationHelper

  def contact_verified(email:, contact:, poi:)
    @contact = contact
    subject = 'Successful Contact Verification'
    attachments['proof_of_identity.pdf'] = poi
    mail(to: email, subject: subject)
  end
end
