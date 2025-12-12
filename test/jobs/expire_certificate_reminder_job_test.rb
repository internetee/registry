require 'test_helper'

class ExpireCertificateReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @certificate = certificates(:api)
    
    create_setting_if_not_exists('certificate_reminder_deadline', '30', 'integer', 'certificate')
  end

  def test_sends_reminder_for_expiring_certificate
    @certificate.update(expires_at: 2.weeks.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 1
    
    email = ActionMailer::Base.deliveries.last
    assert_equal @certificate.api_user.registrar.email, email.to.first
    assert_match 'Certificate Expiring', email.subject
  end

  def test_does_not_send_reminder_for_certificate_expiring_later
    @certificate.update(expires_at: 2.months.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 0
  end

  def test_sends_reminder_for_multiple_expiring_certificates
    second_certificate = certificates(:registrar)
    @certificate.update(expires_at: 1.week.from_now)
    second_certificate.update(expires_at: 3.weeks.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 2
  end

  def test_uses_custom_deadline_setting
    update_setting('certificate_reminder_deadline', '10')
    
    @certificate.update(expires_at: 2.weeks.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 0
    
    @certificate.update(expires_at: 5.days.from_now)
    
    perform_enqueued_jobs do
      ExpireCertificateReminderJob.perform_now
    end

    assert_emails 1
  end

  private

  def create_setting_if_not_exists(code, value, format, group)
    unless SettingEntry.exists?(code: code)
      SettingEntry.create!(code: code, value: value, format: format, group: group)
    end
  end

  def update_setting(code, value)
    setting = SettingEntry.find_by(code: code)
    setting.update!(value: value) if setting
  end
end
