class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app/views/mailers')
  layout 'mailer'

  def log_pending_notification(domain, kind, recipients)
    DomainPendingNotification.create!(domain: domain, kind: kind, recipients: Array(recipients))
  end

  def registrant_confirm_url(domain:, method:)
    token = domain.registrant_verification_token
    base_url = ENV['registrant_portal_verifications_base_url']

    "#{base_url}/confirmation/#{domain.name_puny}/#{method}/#{token}"
  end
end
