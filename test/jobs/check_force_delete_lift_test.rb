require 'test_helper'

class CheckForceDeleteLiftTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    @original_validation_type = Truemail.configure.default_validation_type
    ValidationEvent.destroy_all
    Setting.redemption_grace_period = 30
  end

  teardown do
    Truemail.configure.default_validation_type = @original_validation_type
  end

  def test_updates_status_notes_when_invalid_email_changes
    Truemail.configure.default_validation_type = :regex
    old_invalid_email = '`@invalid-old.ee'
    new_invalid_email = '`@invalid-new.ee'

    contact = @domain.admin_contacts.first

    # Setup: domain in FD due to old invalid email
    @domain.update(
      valid_to: Time.zone.parse('2012-08-05'),
      statuses: [DomainStatus::FORCE_DELETE,
                 DomainStatus::SERVER_RENEW_PROHIBITED,
                 DomainStatus::SERVER_TRANSFER_PROHIBITED],
      force_delete_data: { 'template_name' => 'invalid_email', 'force_delete_type' => 'soft' },
      status_notes: { DomainStatus::FORCE_DELETE => old_invalid_email }
    )

    # Contact changes to new (still invalid) email
    contact.update_attribute(:email, new_invalid_email)

    # Create failed validation events for the new email
    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact.validation_events.create!(
        event_type: :email_validation,
        success: false,
        event_data: { 'check_level' => 'mx', 'email' => new_invalid_email },
        created_at: Time.zone.now
      )
    end

    assert contact.email_verification_failed?, 'Contact should have failed email verification'

    CheckForceDeleteLift.perform_now

    @domain.reload

    assert @domain.force_delete_scheduled?, 'Domain should still be in force delete'
    assert_equal new_invalid_email, @domain.status_notes[DomainStatus::FORCE_DELETE],
                 'Status notes should be updated to reflect current invalid email'
  end

  def test_updates_status_notes_with_multiple_invalid_emails
    Truemail.configure.default_validation_type = :regex
    old_invalid_email = '`@invalid-old.ee'
    new_invalid_email_1 = '`@invalid-new1.ee'
    new_invalid_email_2 = '`@invalid-new2.ee'

    contact = @domain.admin_contacts.first
    registrant = @domain.registrant

    # Setup: domain in FD due to old invalid email
    @domain.update(
      valid_to: Time.zone.parse('2012-08-05'),
      statuses: [DomainStatus::FORCE_DELETE,
                 DomainStatus::SERVER_RENEW_PROHIBITED,
                 DomainStatus::SERVER_TRANSFER_PROHIBITED],
      force_delete_data: { 'template_name' => 'invalid_email', 'force_delete_type' => 'soft' },
      status_notes: { DomainStatus::FORCE_DELETE => old_invalid_email }
    )

    # Contact and registrant both change to new invalid emails
    contact.update_attribute(:email, new_invalid_email_1)
    registrant.update_attribute(:email, new_invalid_email_2)

    # Create failed validation events for both
    [contact, registrant].each do |obj|
      ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
        obj.validation_events.create!(
          event_type: :email_validation,
          success: false,
          event_data: { 'check_level' => 'mx', 'email' => obj.email },
          created_at: Time.zone.now
        )
      end
    end

    CheckForceDeleteLift.perform_now

    @domain.reload

    assert @domain.force_delete_scheduled?, 'Domain should still be in force delete'
    notes = @domain.status_notes[DomainStatus::FORCE_DELETE]
    assert_includes notes, new_invalid_email_1,
                   'Status notes should contain the new invalid contact email'
    assert_includes notes, new_invalid_email_2,
                   'Status notes should contain the new invalid registrant email'
    assert_not_includes notes, old_invalid_email,
                        'Status notes should not contain the old invalid email'
  end

  def test_does_not_update_status_notes_when_they_are_already_correct
    Truemail.configure.default_validation_type = :regex
    invalid_email = '`@invalid.ee'

    contact = @domain.admin_contacts.first

    @domain.update(
      valid_to: Time.zone.parse('2012-08-05'),
      statuses: [DomainStatus::FORCE_DELETE,
                 DomainStatus::SERVER_RENEW_PROHIBITED,
                 DomainStatus::SERVER_TRANSFER_PROHIBITED],
      force_delete_data: { 'template_name' => 'invalid_email', 'force_delete_type' => 'soft' },
      status_notes: { DomainStatus::FORCE_DELETE => invalid_email }
    )

    contact.update_attribute(:email, invalid_email)

    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact.validation_events.create!(
        event_type: :email_validation,
        success: false,
        event_data: { 'check_level' => 'mx', 'email' => invalid_email },
        created_at: Time.zone.now
      )
    end

    original_updated_at = @domain.updated_at

    CheckForceDeleteLift.perform_now

    @domain.reload

    assert_equal invalid_email, @domain.status_notes[DomainStatus::FORCE_DELETE],
                 'Status notes should remain unchanged'
  end

  def test_does_not_update_notes_for_invalid_company_template
    @domain.update(
      valid_to: Time.zone.parse('2012-08-05'),
      statuses: [DomainStatus::FORCE_DELETE,
                 DomainStatus::SERVER_RENEW_PROHIBITED,
                 DomainStatus::SERVER_TRANSFER_PROHIBITED],
      force_delete_data: { 'template_name' => 'invalid_company', 'force_delete_type' => 'soft' },
      status_notes: { DomainStatus::FORCE_DELETE => "Company no: 1234" }
    )

    original_notes = @domain.status_notes[DomainStatus::FORCE_DELETE]

    CheckForceDeleteLift.perform_now

    @domain.reload

    assert_equal original_notes, @domain.status_notes[DomainStatus::FORCE_DELETE],
                 'Status notes for invalid_company should not be modified'
  end
end
