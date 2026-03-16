class ExpireCertificateReminderJob < ApplicationJob
  queue_as :default

  DEADLINE = 1.month
  
  def perform
    Certificate.where('expires_at < ?', DEADLINE.from_now).each do |certificate|
      send_reminder(certificate)
    end
  end

  private

  def send_reminder(certificate)
    registrar = certificate.api_user.registrar

    send_email(registrar, certificate)
  end

  def send_email(registrar, certificate)
    CertificateMailer.certificate_expiring(email: registrar.email, certificate: certificate).deliver_now
  end
end
