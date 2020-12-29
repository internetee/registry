require 'test_helper'

class DomainCronTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    @original_expire_pending_confirmation = Setting.expire_pending_confirmation
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Setting.expire_pending_confirmation = @original_expire_pending_confirmation
  end

  def test_clean_expired_pendings_notifies_registrant_by_email
    Setting.expire_pending_confirmation = 0
    @domain.update!(registrant_verification_asked_at: Time.zone.now,
                    registrant_verification_token: 'test',
                    statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])

    perform_enqueued_jobs do
      DomainCron.clean_expired_pendings
    end

    assert_emails 1
  end

  def test_client_hold
    Setting.redemption_grace_period = 30

    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    @domain.update(template_name: 'legal_person')
    travel_to Time.zone.parse('2010-08-06')
    DomainCron.start_client_hold

    assert_emails 1
  end

  def does_not_deliver_forced_email_if_template_empty
    Setting.redemption_grace_period = 30

    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    @domain.update(template_name: nil)
    travel_to Time.zone.parse('2010-08-06')
    DomainCron.start_client_hold

    assert_emails 0
  end

  def test_does_not_sets_hold_if_already_set
    Setting.redemption_grace_period = 30

    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    @domain.update(template_name: 'legal_person', statuses: [DomainStatus::CLIENT_HOLD])
    travel_to Time.zone.parse('2010-08-06')
    DomainCron.start_client_hold

    assert_emails 0
  end

  def test_cleans_expired_pendings_when_force_delete_active
    Setting.expire_pending_confirmation = 0

    # Set force delete
    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    @domain.statuses << DomainStatus::PENDING_UPDATE
    # Set domain registrant change that's expired
    @domain.update!(registrant_verification_asked_at: Time.zone.now,
                    registrant_verification_token: 'test',
                    statuses: @domain.statuses)

    assert @domain.pending_update?
    @domain.reload

    perform_enqueued_jobs do
      DomainCron.clean_expired_pendings
    end
    @domain.reload

    assert_not @domain.pending_update?
  end
end
