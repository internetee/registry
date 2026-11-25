# frozen_string_literal: true

require 'test_helper'

class Actions::ApiUserApproveVerificationTest < ActiveSupport::TestCase
  setup do
    @api_user = users(:api_bestnames_epp)
    @api_user.update!(
      email: 'pending@example.test',
      ident_request_sent_at: 1.day.ago,
      verification_pending_at: Time.zone.now,
      verification_id: 'pending-1',
      verification_snapshot: {
        'sub' => 'GBMANUAL123'
      }
    )
  end

  test 'approve sets subject and country from verification snapshot' do
    assert Actions::ApiUserApproveVerification.new(@api_user).call

    @api_user.reload
    assert @api_user.verified_at.present?
    assert_nil @api_user.verification_pending_at
    assert_equal 'GBMANUAL123', @api_user.subject
    assert_equal 'GB', @api_user.country_code
    assert_nil @api_user.identity_code
  end

  test 'approve sets subject from manual override when snapshot has no subject' do
    @api_user.update!(verification_snapshot: { 'given_name' => 'Test' })

    assert Actions::ApiUserApproveVerification.new(@api_user, subject: 'EE60001019906').call

    @api_user.reload
    assert_equal 'EE60001019906', @api_user.subject
    assert_equal 'EE', @api_user.country_code
    assert_nil @api_user.identity_code
  end

  test 'approve fails when subject is missing' do
    @api_user.update!(verification_snapshot: { 'given_name' => 'Test' })

    assert_not Actions::ApiUserApproveVerification.new(@api_user).call
    assert @api_user.errors.added?(:base, :missing_subject)
  end

  test 'approve fails when subject conflicts' do
    users(:api_bestnames).update!(
      subject: 'GBMANUAL123',
      registrar: @api_user.registrar
    )

    assert_not Actions::ApiUserApproveVerification.new(@api_user).call
    assert @api_user.errors.added?(:subject, :taken)
  end
end
