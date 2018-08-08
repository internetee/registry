require 'test_helper'

class DomainLockableTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:airport)
  end

  def test_registry_lock_on_lockable_domain
    refute(@domain.locked_by_registrant?)
    @domain.apply_registry_lock

    assert_equal(
      [DomainStatus::SERVER_UPDATE_PROHIBITED,
       DomainStatus::SERVER_DELETE_PROHIBITED,
       DomainStatus::SERVER_TRANSFER_PROHIBITED],
      @domain.statuses
    )

    assert(@domain.locked_by_registrant?)
    assert(@domain.locked_by_registrant_at)
  end

  def test_registry_lock_cannot_be_applied_twice
    @domain.apply_registry_lock
    refute(@domain.apply_registry_lock)
    assert(@domain.locked_by_registrant?)
    assert(@domain.locked_by_registrant_at)
  end

  def test_registry_lock_cannot_be_applied_on_pending_statuses
    @domain.statuses << DomainStatus::PENDING_RENEW
    refute(@domain.apply_registry_lock)
    refute(@domain.locked_by_registrant?)
    refute(@domain.locked_by_registrant_at)
  end

  def test_remove_registry_lock_on_locked_domain
    @domain.apply_registry_lock

    assert_equal(
      [DomainStatus::SERVER_UPDATE_PROHIBITED,
       DomainStatus::SERVER_DELETE_PROHIBITED,
       DomainStatus::SERVER_TRANSFER_PROHIBITED],
      @domain.statuses
    )

    @domain.remove_registry_lock

    assert_equal(["ok"], @domain.statuses)
    refute(@domain.locked_by_registrant?)
    refute(@domain.locked_by_registrant_at)
  end

  def test_remove_registry_lock_on_non_locked_domain
    refute(@domain.locked_by_registrant?)
    refute(@domain.remove_registry_lock)

    assert_equal([], @domain.statuses)
    refute(@domain.locked_by_registrant?)
    refute(@domain.locked_by_registrant_at)
  end

  def test_registry_lock_cannot_be_removed_if_statuses_were_set_by_admin
    @domain.statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    @domain.statuses << DomainStatus::SERVER_DELETE_PROHIBITED
    @domain.statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED

    refute(@domain.remove_registry_lock)
  end
end
