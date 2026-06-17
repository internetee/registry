# frozen_string_literal: true

require 'test_helper'

class Actions::ContactRejectVerificationTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @contact.update!(
      ident_request_sent_at: 1.day.ago,
      verification_pending_at: Time.zone.now,
      verification_id: 'pending-1',
      verification_snapshot: { 'sub' => 'US9999' }
    )
  end

  test 'reject clears pending verification and ident request timestamp' do
    assert Actions::ContactRejectVerification.new(@contact).call

    @contact.reload
    assert_nil @contact.ident_request_sent_at
    assert_nil @contact.verification_pending_at
    assert_nil @contact.verification_id
    assert_equal({}, @contact.verification_snapshot)
    assert_nil @contact.verified_at
  end

  test 'reject fails when not pending verification' do
    @contact.update!(verification_pending_at: nil)

    assert_not Actions::ContactRejectVerification.new(@contact).call
    assert @contact.errors.added?(:base, :not_pending_verification)
  end
end
