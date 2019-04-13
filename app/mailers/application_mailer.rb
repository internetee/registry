class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app', 'views', 'mailers')
  layout 'mailer'

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
