# frozen_string_literal: true

require 'test_helper'

class Actions::ContactApproveVerificationTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @contact.update!(
      ident_request_sent_at: 1.day.ago,
      verification_pending_at: Time.zone.now,
      verification_id: 'pending-1',
      verification_snapshot: {
        'sub' => 'US9999'
      }
    )
  end

  test 'approve sets ident from verification snapshot' do
    assert Actions::ContactApproveVerification.new(@contact).call

    @contact.reload
    assert @contact.verified_at.present?
    assert_nil @contact.verification_pending_at
    assert_equal 'US', @contact.ident_country_code
    assert_equal '9999', @contact.ident
  end

  test 'approve fails when subject is missing' do
    @contact.update!(verification_snapshot: { 'given_name' => 'Test' })

    assert_not Actions::ContactApproveVerification.new(@contact).call
    assert @contact.errors.added?(:base, :missing_subject)
  end
end
