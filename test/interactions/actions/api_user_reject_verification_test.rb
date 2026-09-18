# frozen_string_literal: true

require 'test_helper'

class Actions::ApiUserRejectVerificationTest < ActiveSupport::TestCase
  setup do
    @api_user = users(:api_bestnames_epp)
    @api_user.update!(
      email: 'pending@example.test',
      ident_request_sent_at: 1.day.ago,
      verification_pending_at: Time.zone.now,
      verification_id: 'pending-1',
      verification_snapshot: { 'sub' => 'GBMANUAL123' }
    )
  end

  test 'reject clears pending verification and ident request timestamp' do
    assert Actions::ApiUserRejectVerification.new(@api_user).call

    @api_user.reload
    assert_nil @api_user.ident_request_sent_at
    assert_nil @api_user.verification_pending_at
    assert_nil @api_user.verification_id
    assert_equal({}, @api_user.verification_snapshot)
    assert_nil @api_user.verified_at
  end

  test 'reject fails when not pending verification' do
    @api_user.update!(verification_pending_at: nil)

    assert_not Actions::ApiUserRejectVerification.new(@api_user).call
    assert @api_user.errors.added?(:base, :not_pending_verification)
  end
end
