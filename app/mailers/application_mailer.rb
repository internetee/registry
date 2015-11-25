class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app', 'views', 'mailers')
  default from: 'noreply@internet.ee'
  layout 'mailer'

  def whitelist_blocked?(emails)
    return false if Rails.env.production? || Rails.env.test?

    emails = [emails] unless emails.is_a?(Array)
    emails = emails.flatten
    emails.each do |email|
      next if TEST_EMAILS.include?(email)
      logger.info "EMAIL SENDING WAS BLOCKED BY WHITELIST: #{email}"
      return true
    end
    false
  end

  # turn on delivery on specific (epp) request only, thus rake tasks does not deliver anything
  def delivery_off?(model, deliver_emails = false)
    return false if deliver_emails == true
    logger.info "EMAIL SENDING WAS NOT ACTIVATED " \
      "BY MODEL OBJECT: id ##{model.try(:id)} deliver_emails returned false"
    true
  end

  def format(email)
    local, host = email.split('@')
    host = SimpleIDN.to_ascii(host)
    "#{local}@#{host}"
  end
end
