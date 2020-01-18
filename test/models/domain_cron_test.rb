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

    DomainCron.clean_expired_pendings

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
end
