require_relative 'test_case'

class AutoRenewChangePreferenceTest < AutoRenewTestCase
  def test_plain_disable_cancels_awaiting_cycle_without_notifications
    with_feature do
      cycle = open_cycle
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        outcome = change_preference(enabled: false)
        assert outcome.valid?, outcome.errors.full_messages.join(', ')
        assert_not outcome.result.enabled
        assert_nil outcome.result.reversed_cycle
        attempt(cycle)
      end
      assert_not @domain.reload.auto_renew?
      assert_equal DomainAutoRenewal::CANCELLED, cycle.reload.state
      assert_equal 100, @account.reload.balance
    end
  end

  def test_plain_disable_keeps_paid_grace_and_enabling_or_omitting_the_preference_never_polls
    with_feature do
      cycle = renew_automatically
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        assert_not change_preference(enabled: false).result.enabled
        assert cycle.reload.grace?
        assert_nil cycle.refund_activity_id
        assert_not change_preference.result.enabled
        assert change_preference(enabled: true).result.enabled
      end
      assert cycle.reload.grace?
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_equal 90, @account.reload.balance
    end
  end

  def test_only_sponsor_can_enable_disable_or_reverse
    with_feature do
      cycle = renew_automatically
      @registrar = registrars(:goodnames)
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        [{ enabled: true }, { enabled: false }, { reverse_cycle_id: cycle.uuid }].each do |options|
          assert_command_error(change_preference(**options), 2201)
        end
      end
      assert @domain.reload.auto_renew?
      assert cycle.reload.grace?
      assert_equal 90, @account.reload.balance
    end
  end

  def test_feature_off_rejects_enable_but_allows_disable_and_reverse
    with_feature do
      cycle = renew_automatically
      with_feature(false) do
        assert_no_difference 'Notification.count' do
          assert_command_error(change_preference(enabled: true), 2306)
          assert change_preference(enabled: false).valid?
          assert change_preference(reverse_cycle_id: cycle.uuid).valid?
        end
      end
      assert cycle.reload.reversed?
      assert_equal 100, @account.reload.balance
    end
  end

  def test_enable_and_reverse_is_rejected_without_partial_changes
    with_feature do
      cycle = renew_automatically
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        assert_command_error(change_preference(enabled: true, reverse_cycle_id: cycle.uuid), 2306)
      end
      assert @domain.reload.auto_renew?
      assert cycle.reload.grace?
      assert_equal @expiry.advance(years: 1), @domain.valid_to
    end
  end

  def test_unknown_cycle_and_another_domains_cycle_return_2303
    with_feature do
      cycle = open_cycle
      other = cycle.dup
      other.uuid = SecureRandom.uuid
      other.domain = domains(:airport)
      other.save!
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        [SecureRandom.uuid, other.uuid].each do |id|
          assert_command_error(change_preference(enabled: false, reverse_cycle_id: id), 2303)
        end
      end
      assert @domain.reload.auto_renew?
      assert cycle.reload.awaiting_funds?
    end
  end

  def test_awaiting_cycle_cannot_be_reversed_and_preference_is_unchanged
    with_feature do
      cycle = open_cycle
      assert_command_error(change_preference(enabled: false, reverse_cycle_id: cycle.uuid), 2304)
      assert @domain.reload.auto_renew?
      assert cycle.reload.awaiting_funds?
      assert_equal 0, polls.count
    end
  end

  def test_callers_rollback_includes_preference_and_cycle_changes
    with_feature do
      cycle = open_cycle
      Domain.transaction(requires_new: true) do
        @domain.reload(lock: true)
        outcome = Domains::AutoRenew::ChangePreference.run(domain: @domain, registrar: @registrar, enabled: false)
        assert outcome.valid?
        raise ActiveRecord::Rollback
      end
      assert @domain.reload.auto_renew?
      assert cycle.reload.awaiting_funds?
      assert_equal 0, polls.count
    end
  end
end
