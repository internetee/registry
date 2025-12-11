require 'test_helper'

class ExpireCertificateReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @certificate = certificates(:api)
  end

  def test_sends_reminder_for_expiring_certificate
    # Устанавливаем дату истечения на 2 недели от текущего времени (меньше месяца)
    @certificate.update(expires_at: 2.weeks.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 1
    
    # Проверяем, что письмо отправлено правильному получателю
    email = ActionMailer::Base.deliveries.last
    assert_equal @certificate.api_user.registrar.email, email.to.first
    assert_match 'Certificate Expiring', email.subject
  end

  def test_does_not_send_reminder_for_certificate_expiring_later
    # Устанавливаем дату истечения на 2 месяца от текущего времени (больше месяца)
    @certificate.update(expires_at: 2.months.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 0
  end

  def test_sends_reminder_for_multiple_expiring_certificates
    # Создаем второй сертификат, который тоже скоро истекает
    second_certificate = certificates(:registrar)
    @certificate.update(expires_at: 1.week.from_now)
    second_certificate.update(expires_at: 3.weeks.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 2
  end
end
