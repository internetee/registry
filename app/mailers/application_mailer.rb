class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app/views/mailers')
  layout 'mailer'

  def registrant_confirm_url(domain:, method:)
    token = domain.registrant_verification_token
    base_url = ENV['registrant_portal_verifications_base_url']

    "#{base_url}/confirmation/#{domain.name_puny}/#{method}/#{token}"
  end
end
