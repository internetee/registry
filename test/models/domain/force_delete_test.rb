require 'test_helper'

class DomainForceDeleteTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
  end

  def test_schedule_force_delete
    @original_redemption_grace_period = Setting.redemption_grace_period
    Setting.redemption_grace_period = 30
    travel_to Time.zone.parse('2010-07-05 00:00')

    @domain.schedule_force_delete
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal Time.zone.parse('2010-08-04 03:00'), @domain.force_delete_at

    travel_back
    Setting.redemption_grace_period = @original_redemption_grace_period
  end

  def test_scheduling_force_delete_adds_corresponding_statuses
    statuses_to_be_added = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED,
      DomainStatus::SERVER_UPDATE_PROHIBITED,
      DomainStatus::PENDING_DELETE,
    ]

    @domain.schedule_force_delete
    @domain.reload
    assert (@domain.statuses & statuses_to_be_added) == statuses_to_be_added
  end

  def test_scheduling_force_delete_allows_domain_deletion
    statuses_to_be_removed = [
      DomainStatus::CLIENT_DELETE_PROHIBITED,
      DomainStatus::SERVER_DELETE_PROHIBITED,
    ]

    @domain.statuses = statuses_to_be_removed + %w[other-status]
    @domain.schedule_force_delete
    @domain.reload
    assert_empty @domain.statuses & statuses_to_be_removed
  end

  def test_scheduling_force_delete_stops_pending_actions
    statuses_to_be_removed = [
      DomainStatus::PENDING_UPDATE,
      DomainStatus::PENDING_TRANSFER,
      DomainStatus::PENDING_RENEW,
      DomainStatus::PENDING_CREATE,
    ]

    @domain.statuses = statuses_to_be_removed + %w[other-status]
    @domain.schedule_force_delete
    @domain.reload
    assert_empty @domain.statuses & statuses_to_be_removed, 'Pending actions should be stopped'
  end

  def test_scheduling_force_delete_preserves_current_statuses
    @domain.statuses = %w[test1 test2]
    @domain.schedule_force_delete
    @domain.reload
    assert_equal %w[test1 test2], @domain.statuses_before_force_delete
  end

  def test_scheduling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete
    assert @domain.force_delete_scheduled?
  end

  def test_cancelling_force_delete_on_a_discarded_domain
    @domain.discard
    @domain.schedule_force_delete
    @domain.cancel_force_delete
    @domain.reload
    assert_not @domain.force_delete_scheduled?
    assert_nil @domain.force_delete_at
  end

  def test_cancelling_force_delete_requires_a_domain_to_be_discarded
    @domain.schedule_force_delete
    assert_raises StandardError do
      @domain.cancel_force_delete
    end
  end

  def test_cancelling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.discard
    @domain.schedule_force_delete
    @domain.cancel_force_delete
    assert_not @domain.force_delete_scheduled?
  end

  def test_cancelling_force_delete_removes_statuses_that_were_set_on_force_delete
    statuses = [
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_RENEW_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED,
      DomainStatus::SERVER_UPDATE_PROHIBITED,
      DomainStatus::PENDING_DELETE,
      DomainStatus::SERVER_MANUAL_INZONE
    ]
    @domain.discard
    @domain.statuses = @domain.statuses + statuses
    @domain.schedule_force_delete

    @domain.cancel_force_delete
    @domain.reload

    assert_empty @domain.statuses & statuses
  end

  def test_cancelling_force_delete_restores_statuses_that_a_domain_had_before_force_delete
    @domain.discard
    @domain.statuses_before_force_delete = ['test1', DomainStatus::DELETE_CANDIDATE]

    @domain.cancel_force_delete
    @domain.reload

    assert_equal ['test1', DomainStatus::DELETE_CANDIDATE], @domain.statuses
    assert_nil @domain.statuses_before_force_delete
  end
end
