class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app/views/mailers')
  layout 'mailer'

  # Header read by Observers::PendingNotificationObserver, which logs the email
  # only after it was actually delivered.
  def pending_notification(domain, kind)
    { Observers::PendingNotificationObserver::HEADER => "#{domain.id}:#{kind}" }
  end

  def registrant_confirm_url(domain:, method:)
    token = domain.registrant_verification_token
    base_url = ENV['registrant_portal_verifications_base_url']

    "#{base_url}/confirmation/#{domain.name_puny}/#{method}/#{token}"
  end
end
