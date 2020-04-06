require 'test_helper'

class RegistrantVerificationTest < ActiveSupport::TestCase

  setup do
    @domain = domains(:shop)
    @initiator = users(:api_bestnames).username
    @token = 'zzzzz'
    @domain.update(statuses: [DomainStatus::PENDING_UPDATE],
                   registrant_verification_asked_at: Time.zone.now - 1.day,
                   registrant_verification_token: @token)
  end

  def test_audit_log
    registrant_verification = registrant_verifications(:one)
    random_action = "random#{rand(100)}"

    assert_difference -> { Audit::RegistrantVerificationHistory.count } do
      registrant_verification.update_attributes!(action: random_action)
    end
  end

  def test_reject_changes
    @registrant_verification = RegistrantVerification.new(domain_id: @domain.id,
                                                          verification_token: @token)
    start_versions_count = Audit::RegistrantVerificationHistory.count

    assert_nothing_raised do
      @registrant_verification.domain_registrant_change_reject!("email link, #{@initiator}")
    end
    assert_equal Audit::RegistrantVerificationHistory.count, start_versions_count + 1
  end
end
