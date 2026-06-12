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

  test 'approve fails for birthday contact when snapshot contains id_number' do
    @contact.update!(
      ident_type: Contact::BIRTHDAY,
      ident: '2010-07-05',
      ident_country_code: 'EE',
      verification_snapshot: {
        'date_of_birth' => '2010-07-05',
        'given_name' => 'Child',
        'family_name' => 'Example',
        'country' => 'EE',
        'id_number' => '30303039914'
      }
    )

    assert_not Actions::ContactApproveVerification.new(@contact).call
    assert @contact.errors.added?(:base, :id_number_requires_priv_contact)
    assert_nil @contact.reload.verified_at
  end

  test 'approve succeeds for birthday contact without id_number in snapshot' do
    @contact.update!(
      ident_type: Contact::BIRTHDAY,
      ident: '2010-07-05',
      ident_country_code: 'EE',
      name: 'Child Example',
      verification_snapshot: {
        'date_of_birth' => '2010-07-05',
        'given_name' => 'Child',
        'family_name' => 'Example',
        'country' => 'EE',
        'document_number' => 'AB123456'
      }
    )

    assert Actions::ContactApproveVerification.new(@contact).call

    @contact.reload
    assert @contact.verified_at.present?
    assert_equal '2010-07-05', @contact.ident
    assert_equal 'EE', @contact.ident_country_code
    assert_equal 'Child Example', @contact.name
  end
end
