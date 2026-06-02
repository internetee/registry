class RegistrarMailer < ApplicationMailer
  helper ApplicationHelper

  def contact_verified(email:, contact:, poi:)
    @contact = contact
    subject = default_i18n_subject(contact_code: contact.code)
    attachments['proof_of_identity.pdf'] = poi
    mail(to: email, subject: subject)
  end

  def api_user_verified(email:, api_user:, poi:)
    @api_user = api_user
    subject = default_i18n_subject(username: api_user.username)
    attachments['proof_of_identity.pdf'] = poi
    mail(to: email, subject: subject)
  end

  def api_user_verification_pending(email:, api_user:, poi:)
    @api_user = api_user
    @verification_snapshot = api_user.verification_snapshot
    subject = default_i18n_subject(username: api_user.username)
    attachments['proof_of_identity.pdf'] = poi if poi.present?
    mail(to: email, subject: subject)
  end

  def api_user_subject_changed(email:, api_user:, old_subject:, new_subject:)
    @api_user = api_user
    @old_subject = old_subject
    @new_subject = new_subject
    subject = default_i18n_subject(username: api_user.username)
    mail(to: email, subject: subject)
  end
end
