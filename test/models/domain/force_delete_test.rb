require 'test_helper'

class NewDomainForceDeleteTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    Setting.redemption_grace_period = 30
  end

  def test_schedules_force_delete_fast_track
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload

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
      DomainStatus::SERVER_TRANSFER_PROHIBITED,
    ]

    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    assert (@domain.statuses & statuses_to_be_added) == statuses_to_be_added
  end

  def test_scheduling_fast_track_force_delete_adds_corresponding_statuses
    statuses_to_be_added = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED,
    ]

    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert (@domain.statuses & statuses_to_be_added) == statuses_to_be_added
  end

  def test_scheduling_force_delete_allows_domain_deletion
    statuses_to_be_removed = [
      DomainStatus::CLIENT_DELETE_PROHIBITED,
      DomainStatus::SERVER_DELETE_PROHIBITED,
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
      DomainStatus::PENDING_CREATE,
    ]

    @domain.statuses = statuses_to_be_removed + %w[other-status]
    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert_empty @domain.statuses & statuses_to_be_removed, 'Pending actions should be stopped'
  end

  def test_scheduling_force_delete_preserves_current_statuses
    @domain.statuses = %w[test1 test2]
    @domain.schedule_force_delete(type: :fast_track)
    @domain.reload
    assert_equal %w[test1 test2], @domain.statuses_before_force_delete
  end

  def test_scheduling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete(type: :fast_track)
    assert @domain.force_delete_scheduled?
  end

  def test_force_delete_cannot_be_scheduled_when_a_domain_is_discarded
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])
    result = ForceDeleteInteraction::SetForceDelete.run(domain: @domain, type: :fast_track)

    assert_not result.valid?
    assert_not @domain.force_delete_scheduled?
    message = ["Force delete procedure cannot be scheduled while a domain is discarded"]
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
        DomainStatus::SERVER_TRANSFER_PROHIBITED,
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
        DomainStatus::SERVER_TRANSFER_PROHIBITED,
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
    DomainCron.start_client_hold
    @domain.reload

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
    DomainCron.start_client_hold
    @domain.reload
    assert_includes(@domain.statuses, asserted_status)
  end

  def test_force_delete_soft_year_ahead_not_sets_client_hold_before_threshold
    asserted_status = DomainStatus::CLIENT_HOLD

    @domain.update_columns(valid_to: Time.zone.parse('2010-08-05'),
                           force_delete_date: nil)
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    @domain.schedule_force_delete(type: :soft)

    travel_to Time.zone.parse('2010-07-06')
    DomainCron.start_client_hold
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
    DomainCron.start_client_hold
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
    DomainCron.start_client_hold
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
end
