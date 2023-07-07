class WhiteIpMailer < ApplicationMailer
  def api_ip_address_updated
    email = params[:email]
    @api_user = params[:api_user]
    @white_ip = params[:white_ip]
    subject = '[Important] Whitelisted IP Address Change Notification'
    mail(to: email, subject: subject)
  end

  def api_ip_address_deleted
    email = params[:email]
    @api_user = params[:api_user]
    @white_ip = params[:white_ip]
    subject = '[Important] Whitelisted IP Address Removal Notification'
    mail(to: email, subject: subject)
  end

  def committed(email:, ip:)
    @white_ip = ip
    subject = 'Whitelisted IP Address Activation Confirmation'
    mail(to: email, subject: subject)
  end
end
