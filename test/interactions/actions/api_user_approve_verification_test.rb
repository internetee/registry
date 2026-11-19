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

    action = Actions::ApiUserApproveVerification.new(@api_user)

    assert_not action.call
    assert_equal :subject_taken_by_user, action.failure_reason
    assert @api_user.errors.added?(:base, :subject_taken_by_user,
                                   subject: 'GBMANUAL123', username: users(:api_bestnames).username)
    assert_includes action.failure_message, users(:api_bestnames).username
  end

  test 'approve returns validation errors instead of raising when user data is invalid' do
    @api_user.update_columns(plain_text_password: '123')
    action = Actions::ApiUserApproveVerification.new(@api_user)

    assert_not action.call
    assert_equal :update_failed, action.failure_reason
    assert_equal 1, @api_user.errors.count
    assert_match(/Saving API user data failed: Password is too short/, action.failure_message)

    @api_user.reload
    assert_nil @api_user.verified_at
    assert @api_user.verification_pending_at.present?
    assert_not_equal 'GBMANUAL123', @api_user.subject
  end

  test 'approve logs the failure reason' do
    @api_user.update!(verification_snapshot: {})
    logged = []
    Rails.logger.stub(:warn, ->(msg) { logged << msg }) do
      Actions::ApiUserApproveVerification.new(@api_user).call
    end

    assert(logged.any? { |msg| msg.include?('Manual approval failed') && msg.include?('reason=missing_subject') })
  end
end
