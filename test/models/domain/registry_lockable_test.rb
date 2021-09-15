require 'test_helper'

class DomainRegistryLockableTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:airport)
  end

  def test_user_can_set_lock_for_domain_if_it_has_any_prohibited_status
    refute(@domain.locked_by_registrant?)
    @domain.update(statuses: [DomainStatus::SERVER_TRANSFER_PROHIBITED])

    @domain.apply_registry_lock # Raise validation error

    check_statuses_lockable_domain
    assert(@domain.locked_by_registrant?)
  end

  def test_remove_lockalable_statuses_after_admin_intervention
    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?
    assert_equal @domain.statuses.sort, Domain::RegistryLockable::LOCK_STATUSES.sort

    deleted_status = @domain.statuses - [DomainStatus::SERVER_DELETE_PROHIBITED]
    @domain.update(statuses: deleted_status)
    assert_not @domain.locked_by_registrant?

    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?
    @domain.remove_registry_lock

    assert_not @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
  end

  def test_restore_domain_statuses_after_unlock
    @domain.statuses = [DomainStatus::SERVER_UPDATE_PROHIBITED]
    @domain.admin_store_statuses_history = [DomainStatus::SERVER_UPDATE_PROHIBITED]
    @domain.save
    assert @domain.admin_store_statuses_history.include? DomainStatus::SERVER_UPDATE_PROHIBITED

    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?
    assert_equal @domain.statuses.sort, Domain::RegistryLockable::LOCK_STATUSES.sort

    @domain.remove_registry_lock
    assert @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
  end

  def test_add_additinal_status_for_locked_domain
    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?
    assert_equal @domain.statuses.sort, Domain::RegistryLockable::LOCK_STATUSES.sort

    @domain.statuses += [DomainStatus::SERVER_RENEW_PROHIBITED]
    @domain.admin_store_statuses_history = [DomainStatus::SERVER_RENEW_PROHIBITED]
    @domain.save

    @domain.remove_registry_lock
    assert @domain.statuses.include? DomainStatus::SERVER_RENEW_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
  end

  def test_lockable_domain_if_remove_some_prohibited_status
    refute(@domain.locked_by_registrant?)
    @domain.apply_registry_lock
    check_statuses_lockable_domain
    assert(@domain.locked_by_registrant?)

    statuses = @domain.statuses - [DomainStatus::SERVER_UPDATE_PROHIBITED]
    @domain.update(statuses: statuses)

    assert @domain.statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
    assert @domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    assert_not @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED

    assert_not(@domain.locked_by_registrant?)
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

    assert_equal(['ok'], @domain.statuses)
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

  def test_set_lock_for_domain_with_force_delete_status
		@domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert @domain.force_delete_scheduled?

		assert @domain.apply_registry_lock

		assert @domain.statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
    assert @domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    assert @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED
	end

  private

  def check_statuses_lockable_domain
    lock_statuses = [DomainStatus::SERVER_UPDATE_PROHIBITED,
                     DomainStatus::SERVER_DELETE_PROHIBITED,
                     DomainStatus::SERVER_TRANSFER_PROHIBITED]

    @domain.statuses.include? lock_statuses
  end
end
