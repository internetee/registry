require 'test_helper'

class ForceDeleteDailyAdminNotifierJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    travel_to Time.zone.parse('2010-07-05')
    ActionMailer::Base.deliveries.clear
  end

  def test_sends_notification_for_domains_with_force_delete_today
    @domain.schedule_force_delete(type: :soft)
    @domain.update!(force_delete_start: Time.zone.now.to_date)
    @domain.reload

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, @domain.name
    assert_includes email.body.to_s, @domain.force_delete_type
  end

  def test_does_not_send_notification_when_no_force_delete_domains_today
    travel_to Time.zone.parse('2010-07-06')
    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert_no_emails do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end
  end

  def test_includes_multiple_domains_in_notification
    @domain.schedule_force_delete(type: :soft)
    @domain.update!(force_delete_start: Time.zone.now.to_date)
    
    domain2 = domains(:airport)
    domain2.schedule_force_delete(type: :fast_track)
    domain2.update!(force_delete_start: Time.zone.now.to_date)
    
    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, @domain.name
    assert_includes email.body.to_s, domain2.name
  end

  def test_includes_correct_reason_for_invalid_email_template
    @domain.update!(template_name: 'invalid_email')
    @domain.schedule_force_delete(type: :soft)
    @domain.update!(force_delete_start: Time.zone.now.to_date)
    @domain.reload

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, 'invalid_email'
  end

  def test_includes_correct_reason_for_manual_force_delete
    manual_reason = "Manual deletion requested"
    @domain.status_notes = { DomainStatus::FORCE_DELETE => manual_reason }
    @domain.schedule_force_delete(type: :fast_track)
    @domain.update!(force_delete_start: Time.zone.now.to_date)
    @domain.reload

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, "Manual force delete: #{manual_reason}"
  end
end 