require_relative 'test_case'

class AutoRenewHandleRegistrantChangeTest < AutoRenewTestCase
  setup do
    @verification = Setting.request_confirmation_on_registrant_change_enabled
    Setting.request_confirmation_on_registrant_change_enabled = false
  end

  teardown do
    Setting.request_confirmation_on_registrant_change_enabled = @verification
  end

  def test_direct_registrant_change_completes_grace_without_refund_or_poll
    with_feature do
      cycle = renew_automatically
      expiry = @domain.reload.valid_to
      balance = @account.reload.balance

      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        change_registrant
        assert_command_error change_preference(reverse_cycle_id: cycle.uuid), 2304
      end

      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      assert_equal Time.zone.now, cycle.closed_at
      assert_nil cycle.refund_activity_id
      assert_equal balance, @account.reload.balance
      assert_equal expiry, @domain.reload.valid_to
      assert @domain.auto_renew?
    end
  end

  def test_same_ident_contact_swap_leaves_grace_reversible
    with_feature do
      cycle = renew_automatically
      contacts(:william).update_column(:ident, @domain.registrant.ident)

      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        change_registrant
      end

      assert_equal contacts(:william).id, @domain.reload.registrant_id
      assert cycle.reload.grace?
      assert cycle.reversible?
      assert_nil cycle.closed_at
    end
  end

  def test_registrant_change_leaves_awaiting_funds_open_for_daily_retry
    with_feature do
      @account.update!(balance: 0)
      cycle = open_cycle
      attempt(cycle)
      last_attempt = cycle.reload.last_attempt_at

      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        change_registrant
      end

      assert cycle.reload.awaiting_funds?
      assert_nil cycle.closed_at
      assert_equal last_attempt, cycle.last_attempt_at
      assert_equal @expiry, @domain.reload.valid_to
      assert @domain.auto_renew?

      @account.update!(balance: 100)
      travel_to last_attempt + DomainAutoRenewal::RETRY_INTERVAL
      attempt(cycle)
      assert cycle.reload.grace?
      assert_equal 2, cycle.attempts_count
    end
  end

  def test_pending_change_leaves_grace_reversible_until_confirmation
    with_feature do
      Setting.request_confirmation_on_registrant_change_enabled = true
      cycle = renew_automatically
      old_registrant_id = @domain.registrant_id
      expiry = @domain.reload.valid_to
      balance = @account.reload.balance

      change_registrant
      assert_equal old_registrant_id, @domain.reload.registrant_id
      assert @domain.pending_update?
      assert @domain.registrant_verification_asked?
      assert cycle.reload.grace?
      assert cycle.reversible?
      assert_nil cycle.closed_at

      assert_no_difference ['AccountActivity.count', 'polls.count'] do
        outcome = Domains::UpdateConfirm::ProcessUpdateConfirmed.run(
          domain: Domain.find(@domain.id), action: RegistrantVerification::CONFIRMED
        )
        assert outcome.valid?, outcome.errors.full_messages.join(', ')
      end

      assert_equal contacts(:william).id, @domain.reload.registrant_id
      assert_not @domain.pending_update?
      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      assert_equal Time.zone.now, cycle.closed_at
      assert_not cycle.reversible?
      assert_nil cycle.refund_activity_id
      assert_equal expiry, @domain.valid_to
      assert_equal balance, @account.reload.balance
      assert @domain.auto_renew?
    end
  end

  def test_model_save_completes_overdue_grace_and_preserves_saved_changes
    with_feature do
      cycle = renew_automatically
      travel_to cycle.cancellation_deadline_at
      old_registrant_id = @domain.registrant_id
      @domain.auto_renew = false
      @domain.registrant_id = contacts(:william).id

      with_feature(false) do
        assert_no_difference ['AccountActivity.count', 'Notification.count'] do
          @domain.save!
          Domains::AutoRenew::HandleRegistrantChange.run!(domain: @domain)
        end
      end

      assert_equal [old_registrant_id, contacts(:william).id], @domain.saved_change_to_registrant_id
      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      assert_equal Time.zone.now, cycle.closed_at
      assert_not @domain.reload.auto_renew?
    end
  end

  def test_missing_previous_registrant_leaves_grace_untouched
    with_feature do
      cycle = renew_automatically

      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        Domains::AutoRenew::HandleRegistrantChange.run!(domain: Domain.find(@domain.id))
      end

      assert cycle.reload.grace?
      assert_nil cycle.closed_at
    end
  end

  private

  def change_registrant
    @domain = Epp::Domain.find(@domain.id)
    action = Actions::DomainUpdate.new(@domain, {
      registrar: @registrar.id,
      registrant: { code: contacts(:william).code, verified: false },
    }, false)
    assert action.call, @domain.errors.full_messages.join(', ')
  end
end
