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

  test 'pending review for birthday contact when result contains id_number' do
    @contact.update!(
      ident_type: Contact::BIRTHDAY,
      ident: '2010-07-05',
      ident_country_code: 'EE',
      name: 'Child Example'
    )

    action = Actions::ProcessContactIdentificationWebhook.new(
      @contact,
      identification_request_id: '125',
      result: {
        date_of_birth: '2010-07-05',
        given_name: 'Child',
        family_name: 'Example',
        country: 'EE',
        id_number: '30303039914'
      }
    )

    assert action.call
    assert_equal :pending_review, action.outcome

    @contact.reload
    assert @contact.verification_pending_at.present?
    assert_equal '30303039914', @contact.verification_snapshot['id_number']
  end
end
