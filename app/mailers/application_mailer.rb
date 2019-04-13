class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app', 'views', 'mailers')
  layout 'mailer'
end