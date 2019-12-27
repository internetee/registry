require 'test_helper'

class RegistrantVerificationTest < ActiveSupport::TestCase
  def test_audit_log
    registrant_verification = registrant_verifications(:one)
    random_action = "random#{rand(100)}"

    assert_difference -> { RegistrantVerificationVersion.count } do
      registrant_verification.update_attributes!(action: random_action)
    end
  end
end
