class ExpireCertificateReminderJob < ApplicationJob
  queue_as :default
  
  def perform
    deadline_days = Setting.certificate_reminder_deadline || 30
    deadline = deadline_days.days.from_now
    
    Certificate.where('expires_at < ?', deadline).where(reminder_sent: false).each do |certificate|
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
    certificate.update(reminder_sent: true)
  end
end
