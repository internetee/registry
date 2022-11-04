require 'test_helper'

class ForceDeleteTest < ActionMailer::TestCase
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    Setting.redemption_grace_period = 30
    ActionMailer::Base.deliveries.clear
    @old_validation_type = Truemail.configure.default_validation_type
    ValidationEvent.destroy_all
  end

  teardown do
    Truemail.configure.default_validation_type = @old_validation_type
  end

  def test_restore_domain_statuses_after_soft_force_delete
    @domain.update(statuses: [DomainStatus::SERVER_RENEW_PROHIBITED])
    @domain.schedule_force_delete(type: :soft)

    assert @domain.force_delete_scheduled?

    assert @domain.force_delete_domain_statuses_history.include? DomainStatus::SERVER_RENEW_PROHIBITED

    @domain.cancel_force_delete
    assert @domain.statuses.include? DomainStatus::SERVER_RENEW_PROHIBITED
  end

  def test_clear_force_delete_domain_statuses_history
    @domain.update(statuses: [DomainStatus::SERVER_RENEW_PROHIBITED])
    @domain.schedule_force_delete(type: :soft)

    assert @domain.force_delete_scheduled?
    assert @domain.force_delete_domain_statuses_history.include? DomainStatus::SERVER_RENEW_PROHIBITED
    @domain.cancel_force_delete

    assert_nil @domain.force_delete_domain_statuses_history
  end

  def test_schedules_force_delete_fast_track
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :fast_track, notify_by_email: true)
    @domain.reload

    assert_emails 1
    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-08-20'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-07-06'), @domain.force_delete_start.to_date
  end

  def test_schedules_force_delete_soft_year_ahead
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
  end

  def test_schedules_force_delete_soft_less_than_year_ahead
    @domain.update_columns(valid_to: Time.zone.parse('2010-08-05'),
                           force_delete_date: nil)
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_nil @domain.force_delete_date
    assert_nil @domain.force_delete_start
  end

  def test_scheduling_soft_force_delete_adds_corresponding_statuses
    statuses_to_be_added = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED
    ]

    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    assert (@domain.statuses & statuses_to_be_added) == statuses_to_be_added
  end

  def test_scheduling_fast_track_force_delete_adds_corresponding_statuses
    statuses_to_be_added = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED
    ]

    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert (@domain.statuses & statuses_to_be_added) == statuses_to_be_added
  end

  def test_scheduling_force_delete_allows_domain_deletion
    statuses_to_be_removed = [
      DomainStatus::CLIENT_DELETE_PROHIBITED
    ]

    @domain.statuses = statuses_to_be_removed + %w[other-status]
    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert_empty @domain.statuses & statuses_to_be_removed
  end

  def test_scheduling_force_delete_stops_pending_actions
    Setting.redemption_grace_period = 45
    statuses_to_be_removed = [
      DomainStatus::PENDING_UPDATE,
      DomainStatus::PENDING_TRANSFER,
      DomainStatus::PENDING_RENEW,
      DomainStatus::PENDING_CREATE
    ]

    @domain.statuses = statuses_to_be_removed + %w[other-status]
    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert_empty @domain.statuses & statuses_to_be_removed, 'Pending actions should be stopped'
  end

  def test_scheduling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete(type: :fast_track)
    assert @domain.force_delete_scheduled?
  end

  def test_force_delete_cannot_be_scheduled_when_a_domain_is_discarded
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])
    result = Domains::ForceDelete::SetForceDelete.run(domain: @domain, type: :fast_track)

    assert_not result.valid?
    assert_not @domain.force_delete_scheduled?
    message = ['Force delete procedure cannot be scheduled while a domain is discarded']
    assert_equal message, result.errors.messages[:domain]
  end

  def test_cancels_force_delete
    @domain.update_columns(statuses: [DomainStatus::FORCE_DELETE],
                           force_delete_date: Time.zone.parse('2010-07-05'),
                           force_delete_start: Time.zone.parse('2010-07-05') - 45.days)
    assert @domain.force_delete_scheduled?

    @domain.cancel_force_delete
    @domain.reload

    assert_not @domain.force_delete_scheduled?
    assert_nil @domain.force_delete_date
    assert_nil @domain.force_delete_start
  end

  def test_cancelling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete(type: :fast_track)
    @domain.cancel_force_delete
    assert_not @domain.force_delete_scheduled?
  end

  def test_force_delete_does_not_double_statuses
    statuses = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED
    ]
    @domain.statuses = @domain.statuses + statuses
    @domain.save!
    @domain.reload
    @domain.schedule_force_delete(type: :fast_track)
    assert_equal @domain.statuses.size, statuses.size
  end

  def test_cancelling_force_delete_removes_force_delete_status
    @domain.schedule_force_delete(type: :fast_track)

    assert @domain.statuses.include?(DomainStatus::FORCE_DELETE)
    assert @domain.statuses.include?(DomainStatus::SERVER_RENEW_PROHIBITED)
    assert @domain.statuses.include?(DomainStatus::SERVER_TRANSFER_PROHIBITED)

    @domain.cancel_force_delete
    @domain.reload

    assert_not @domain.statuses.include?(DomainStatus::FORCE_DELETE)
    assert_not @domain.statuses.include?(DomainStatus::SERVER_RENEW_PROHIBITED)
    assert_not @domain.statuses.include?(DomainStatus::SERVER_TRANSFER_PROHIBITED)
  end

  def test_cancelling_force_delete_keeps_previous_statuses
    statuses = [
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED
    ]

    @domain.statuses = statuses
    @domain.save!
    @domain.reload

    @domain.schedule_force_delete(type: :fast_track)
    @domain.cancel_force_delete
    @domain.reload

    assert_equal @domain.statuses, statuses
  end

  def test_hard_force_delete_should_have_outzone_and_purge_date_with_time
    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload

    assert_equal(@domain.purge_date.to_date, @domain.force_delete_date)
    assert_equal(@domain.outzone_date.to_date, @domain.force_delete_start.to_date +
                                               Setting.expire_warning_period.days)
    assert(@domain.purge_date.is_a?(ActiveSupport::TimeWithZone))
    assert(@domain.outzone_date.is_a?(ActiveSupport::TimeWithZone))
  end

  def test_soft_force_delete_year_ahead_should_have_outzone_and_purge_date_with_time
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    @domain.update(template_name: 'legal_person')
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :soft)

    travel_to Time.zone.parse('2010-08-21')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    assert_emails 1
    assert_equal(@domain.purge_date.to_date, @domain.force_delete_date.to_date)
    assert_equal(@domain.outzone_date.to_date, @domain.force_delete_start.to_date +
        Setting.expire_warning_period.days)
    assert(@domain.purge_date.is_a?(ActiveSupport::TimeWithZone))
    assert(@domain.outzone_date.is_a?(ActiveSupport::TimeWithZone))
  end

  def test_force_delete_soft_year_ahead_sets_client_hold
    asserted_status = DomainStatus::CLIENT_HOLD

    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    @domain.update(template_name: 'legal_person')
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)

    travel_to Time.zone.parse('2010-08-21')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    assert_emails 1
    assert_includes(@domain.statuses, asserted_status)
  end

  def test_client_hold_prohibits_manual_inzone
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    @domain.update(template_name: 'legal_person')
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)
    travel_to Time.zone.parse('2010-08-21')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    @domain.statuses << DomainStatus::SERVER_MANUAL_INZONE
    assert_not @domain.valid?
  end

  def test_force_delete_soft_year_ahead_not_sets_client_hold_before_threshold
    asserted_status = DomainStatus::CLIENT_HOLD

    @domain.update_columns(valid_to: Time.zone.parse('2010-08-05'),
                           force_delete_date: nil)
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)

    travel_to Time.zone.parse('2010-07-06')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    assert_not_includes(@domain.statuses, asserted_status)
  end

  def test_force_delete_fast_track_sets_client_hold
    asserted_status = DomainStatus::CLIENT_HOLD
    @domain.update_columns(valid_to: Time.zone.parse('2010-10-05'),
                           force_delete_date: nil)

    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :fast_track)
    travel_to Time.zone.parse('2010-07-25')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    assert_includes(@domain.statuses, asserted_status)
  end

  def test_not_sets_hold_before_treshold
    asserted_status = DomainStatus::CLIENT_HOLD
    @domain.update_columns(valid_to: Time.zone.parse('2010-10-05'),
                           force_delete_date: nil)
    @domain.update(template_name: 'legal_person')

    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :fast_track)
    travel_to Time.zone.parse('2010-07-06')
    Domains::ClientHold::SetClientHold.run!
    @domain.reload

    assert_not_includes(@domain.statuses, asserted_status)
  end

  def test_force_delete_does_not_affect_pending_update_check
    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    @domain.statuses << DomainStatus::PENDING_UPDATE

    assert @domain.force_delete_scheduled?
    assert @domain.pending_update?
  end

  def test_force_delete_does_not_affect_registrant_update_confirmable
    @domain.schedule_force_delete(type: :soft)
    @domain.registrant_verification_asked!('test', User.last.id)
    @domain.save!
    @domain.reload

    @domain.statuses << DomainStatus::PENDING_UPDATE

    assert @domain.force_delete_scheduled?
    assert @domain.registrant_update_confirmable?(@domain.registrant_verification_token)
  end

  def test_schedules_force_delete_after_bounce
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = @domain.admin_contacts.first.email
    asserted_text = "Invalid email: #{email}"

    prepare_bounced_email_address(email)

    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
    notification = @domain.registrar.notifications.last
    assert notification.text.include? asserted_text
  end

  def test_schedules_force_delete_after_registrant_bounce
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = @domain.registrant.email
    asserted_text = "Invalid email: #{email}"

    prepare_bounced_email_address(email)

    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
    notification = @domain.registrar.notifications.last
    assert notification.text.include? asserted_text
  end

  def test_schedules_force_delete_invalid_contact
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = '`@internet.ee'
    asserted_text = "Invalid email: #{email}"

    Truemail.configure.default_validation_type = :regex

    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)

    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact.verify_email
    end

    perform_check_force_delete_job(contact.id)
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
    assert_equal @domain.status_notes[DomainStatus::FORCE_DELETE], email
    notification = @domain.registrar.notifications.last
    assert notification.text.include? asserted_text
  end

  def test_add_invalid_email_to_domain_status_notes
    domain = domains(:airport)
    domain.update(valid_to: Time.zone.parse('2012-08-05'),
                  statuses: %w[serverForceDelete serverRenewProhibited serverTransferProhibited],
                  force_delete_data: { 'template_name': 'invalid_email', 'force_delete_type': 'soft' },
                  status_notes: { "serverForceDelete": '`@internet2.ee' })

    travel_to Time.zone.parse('2010-07-05')
    email = '`@internet.ee'
    invalid_emails = '`@internet2.ee `@internet.ee'
    asserted_text = "Invalid email: #{invalid_emails}"

    Truemail.configure.default_validation_type = :regex

    contact_first = domain.admin_contacts.first
    contact_first.update_attribute(:email_history, 'john@inbox.test')
    contact_first.update_attribute(:email, email)

    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact_first.verify_email
    end

    perform_check_force_delete_job(contact_first.id)
    domain.reload

    assert_equal domain.status_notes[DomainStatus::FORCE_DELETE], invalid_emails
    notification = domain.registrar.notifications.last
    assert_not notification.text.include? asserted_text
  end

  def test_remove_invalid_email_from_domain_status_notes
    domain = domains(:airport)
    domain.update(valid_to: Time.zone.parse('2012-08-05'),
                  statuses: %w[serverForceDelete serverRenewProhibited serverTransferProhibited],
                  force_delete_data: { 'template_name': 'invalid_email', 'force_delete_type': 'soft' },
                  status_notes: { "serverForceDelete": '`@internet2.ee `@internet.ee' })

    travel_to Time.zone.parse('2010-07-05')
    email = '`@internet2.ee'
    invalid_email = '`@internet.ee'
    asserted_text = "Invalid email: #{invalid_email}"

    Truemail.configure.default_validation_type = :regex

    contact_first = domain.admin_contacts.first
    contact_first.update_attribute(:email_history, email)
    contact_first.update_attribute(:email, 'john@inbox.test')

    travel_to Time.zone.parse('2010-07-05 0:00:03')
    contact_first.verify_email

    perform_enqueued_jobs { CheckForceDeleteLift.perform_now }
    domain.reload

    assert_nil domain.status_notes[DomainStatus::FORCE_DELETE]
    assert_not domain.force_delete_scheduled?
  end

  def test_domain_should_have_several_bounced_emails
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email_one = '`@internet.ee'
    email_two = '@@internet.ee'

    contact_one = @domain.admin_contacts.first
    contact_one.update_attribute(:email, email_one)
    contact_one.verify_email
    perform_check_force_delete_job(contact_one.id)

    assert contact_one.need_to_start_force_delete?

    contact_two = @domain.admin_contacts.first
    contact_two.update_attribute(:email, email_two)
    contact_two.verify_email
    perform_check_force_delete_job(contact_two.id)

    assert contact_two.need_to_start_force_delete?

    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
    assert @domain.status_notes[DomainStatus::FORCE_DELETE].include? email_one
    assert @domain.status_notes[DomainStatus::FORCE_DELETE].include? email_two
  end

  def test_lifts_force_delete_after_bounce_changes
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = @domain.registrant.email
    asserted_text = "Invalid email: #{email}"

    prepare_bounced_email_address(email)

    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date
    notification = @domain.registrar.notifications.last
    assert notification.text.include? asserted_text

    @domain.registrant.update(email: 'aaa@bbb.com', email_history: email)
    @domain.registrant.verify_email
    assert @domain.registrant.need_to_lift_force_delete?
    CheckForceDeleteLift.perform_now

    @domain.reload
    assert_not @domain.force_delete_scheduled?
  end

  def test_notification_multiyear_expiration_domain
    @domain.update(valid_to: Time.zone.parse('2014-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Date.parse('2010-09-19'), @domain.force_delete_date.to_date
    assert_equal Date.parse('2010-08-05'), @domain.force_delete_start.to_date

    assert_enqueued_jobs 4
  end

  def prepare_bounced_email_address(email)
    @bounced_mail = BouncedMailAddress.new
    @bounced_mail.email = email
    @bounced_mail.message_id = '010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000'
    @bounced_mail.bounce_type = 'Permanent'
    @bounced_mail.bounce_subtype = 'General'
    @bounced_mail.action = 'failed'
    @bounced_mail.status = '5.1.1'
    @bounced_mail.diagnostic = 'smtp; 550 5.1.1 user unknown'
    @bounced_mail.save!
  end

  private

  def perform_check_force_delete_job(contact_id)
    perform_enqueued_jobs do
      CheckForceDeleteJob.perform_now([contact_id])
    end
  end
end
