# frozen_string_literal: true

require 'test_helper'

class Actions::ProcessContactIdentificationWebhookTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @contact.update!(ident_request_sent_at: 1.day.ago)
  end

  test 'auto verifies when sub matches contact ident' do
    action = Actions::ProcessContactIdentificationWebhook.new(
      @contact,
      identification_request_id: '123',
      result: { sub: 'US1234' }
    )

    assert action.call
    assert_equal :auto_verified, action.outcome

    @contact.reload
    assert @contact.verified_at.present?
    assert_nil @contact.verification_pending_at
    assert_equal '123', @contact.verification_id
  end

  test 'pending review when sub mismatches contact ident' do
    action = Actions::ProcessContactIdentificationWebhook.new(
      @contact,
      identification_request_id: '124',
      result: { sub: 'US9999', given_name: 'John' }
    )

    assert action.call
    assert_equal :pending_review, action.outcome

    @contact.reload
    assert_nil @contact.verified_at
    assert @contact.verification_pending_at.present?
    assert_equal 'US9999', @contact.verification_snapshot['sub']
  end
end
