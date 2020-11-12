class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app', 'views', 'mailers')
  layout 'mailer'

  def registrant_confirm_url(domain:, method:)
    token = domain.registrant_verification_token
    base_url = ENV['registrant_portal_verifications_base_url']

    url = registrant_domain_delete_confirm_url(domain, token: token) if method == 'delete'
    url ||= registrant_domain_update_confirm_url(domain, token: token)
    return url if base_url.blank?

    "#{base_url}/confirms/#{domain.name_puny}/#{method}/#{token}"
  end
end
