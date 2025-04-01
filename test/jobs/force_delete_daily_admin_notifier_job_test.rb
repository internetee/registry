require 'test_helper'

class ForceDeleteDailyAdminNotifierJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    travel_to Time.zone.parse('2010-07-05')
    ActionMailer::Base.deliveries.clear
  end

  def test_sends_notification_for_domains_with_force_delete_today
    @domain.schedule_force_delete(type: :soft,
                                  notify_by_email: true,
                                  reason: 'invalid_email')
    @domain.reload

    travel_to Time.zone.now + 1.day

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, @domain.name
    assert_includes email.body.to_s, @domain.force_delete_type
  end

  def test_includes_multiple_domains_in_notification
    @domain.schedule_force_delete(type: :soft)
    domain2 = domains(:airport)
    domain2.schedule_force_delete(type: :fast_track)
    
    travel_to Time.zone.now + 1.day

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
    @domain.reload

    travel_to Time.zone.now + 1.day

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, 'invalid_email'
  end

  def test_includes_correct_reason_for_manual_force_delete
    @domain.schedule_force_delete(type: :fast_track,
                                  notify_by_email: true,
                                  reason: 'invalid_company')
    @domain.reload

    travel_to Time.zone.now + 1.day

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, "Company no: #{@domain.registrant.ident}"
  end

  def test_includes_lifted_force_delete_domains_in_notification
    reason = "invalid_company"
    @domain.schedule_force_delete(type: :fast_track,
                                  notify_by_email: true,
                                  reason: reason)
    @domain.reload

    assert @domain.force_delete_scheduled?

    @domain.cancel_force_delete
    @domain.reload

    travel_to Time.zone.now + 1.day

    assert_emails 1 do
      ForceDeleteDailyAdminNotifierJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, @domain.name
    assert_includes email.body.to_s, "Company no: #{@domain.registrant.ident}"
  end
end 