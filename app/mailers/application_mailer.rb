class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app', 'views', 'mailers')
  default from: 'noreply@internet.ee'
  layout 'mailer'

  def format(email)
    local, host = email.split('@')
    host = SimpleIDN.to_ascii(host)
    "#{local}@#{host}"
  end
end
