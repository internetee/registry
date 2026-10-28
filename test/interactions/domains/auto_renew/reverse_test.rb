require_relative 'test_case'

class AutoRenewReverseTest < AutoRenewTestCase
  def test_exact_refund_restores_past_expiry_and_its_graceful_expiry_fields_without_polling
    with_feature do
      cycle = renew_automatically
      charge = cycle.charge_activity
      @price.update!(price_cents: 2000)
      outcome = nil
      assert_no_difference 'Notification.count' do
        assert_difference 'AccountActivity.count', 1 do
          outcome = change_preference(enabled: false, reverse_cycle_id: cycle.uuid)
        end
      end
      assert outcome.valid?, outcome.errors.full_messages.join(', ')
      assert_not outcome.result.enabled
      assert_not outcome.result.already_reversed
      assert_equal cycle, outcome.result.reversed_cycle
      refund = outcome.result.refund_activity
      assert_equal AccountActivity::REFUND, refund.activity_type
      assert_equal(-charge.sum, refund.sum)
      assert_equal charge.currency, refund.currency
      assert_equal charge.price_id, refund.price_id
      assert_equal cycle.account_id, refund.account_id
      assert_equal 100, @account.reload.balance
      assert_equal @expiry, @domain.reload.valid_to
      assert_not @domain.auto_renew?
      assert_includes @domain.statuses, DomainStatus::EXPIRED
      assert_equal @expiry + Domain.expire_warning_period, @domain.outzone_at
      assert_equal (@domain.outzone_at + Domain.redemption_grace_period).to_date, @domain.delete_date
      assert cycle.reload.reversed?
      assert_equal refund.id, cycle.refund_activity_id
      assert_equal Time.zone.now, cycle.closed_at
      assert_equal 'renewed', polls.order(:id).last.event
    end
  end

  def test_reversal_preserves_extra_independently_purchased_time_and_other_domain_changes
    with_feature do
      cycle = renew_automatically
      @domain.reload
      @domain.assign_renewal_expiry(cycle.renewed_expire_at.advance(years: 2))
      @domain.statuses |= [DomainStatus::CLIENT_UPDATE_PROHIBITED]
      @domain.save!(validate: false)
      assert change_preference(reverse_cycle_id: cycle.uuid).valid?
      assert_equal @expiry.advance(years: 2), @domain.reload.valid_to
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date
      assert_not_includes @domain.statuses, DomainStatus::EXPIRED
      assert_includes @domain.statuses, DomainStatus::CLIENT_UPDATE_PROHIBITED
      assert_equal 100, @account.reload.balance
    end
  end

  def test_repeat_returns_the_same_refund_even_after_the_deadline
    with_feature do
      cycle = renew_automatically
      first = change_preference(reverse_cycle_id: cycle.uuid)
      assert first.valid?
      expiry = @domain.reload.valid_to
      travel_to cycle.cancellation_deadline_at
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        repeated = change_preference(reverse_cycle_id: cycle.uuid)
        assert repeated.valid?
        assert repeated.result.already_reversed
        assert_equal first.result.refund_activity, repeated.result.refund_activity
      end
      assert_equal expiry, @domain.reload.valid_to
      assert_equal 100, @account.reload.balance
    end
  end

  def test_reversal_at_or_after_deadline_fails_atomically_before_the_sweep_closes_grace
    with_feature do
      cycle = renew_automatically
      domain_before = @domain.reload.attributes
      cycle_before = cycle.attributes
      [cycle.cancellation_deadline_at, cycle.cancellation_deadline_at + 1.second].each do |at|
        travel_to at
        assert_no_difference ['AccountActivity.count', 'Notification.count'] do
          assert_command_error(change_preference(enabled: false, reverse_cycle_id: cycle.uuid), 2304)
        end
        assert_equal domain_before, @domain.reload.attributes
        assert_equal cycle_before, cycle.reload.attributes
        assert_equal 90, @account.reload.balance
      end
    end
  end

  def test_reversal_rolls_back_expiry_preference_and_refund_on_later_caller_failure
    with_feature do
      cycle = renew_automatically
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        Domain.transaction(requires_new: true) do
          @domain.reload(lock: true)
          outcome = Domains::AutoRenew::ChangePreference.run(
            domain: @domain, registrar: @registrar, reverse_cycle_id: cycle.uuid
          )
          assert outcome.valid?
          raise ActiveRecord::Rollback
        end
      end
      assert cycle.reload.grace?
      assert_nil cycle.refund_activity_id
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert @domain.auto_renew?
      assert_equal 90, @account.reload.balance
    end
  end

  def test_direct_reverse_enforces_sponsorship_and_unknown_cycle_errors
    with_feature do
      cycle = renew_automatically
      outcome = Domains::AutoRenew::Reverse.run(domain: @domain, registrar: registrars(:goodnames), cycle_id: cycle.uuid)
      assert_command_error outcome, 2201
      outcome = Domains::AutoRenew::Reverse.run(domain: @domain, registrar: @registrar, cycle_id: SecureRandom.uuid)
      assert_command_error outcome, 2303
      assert cycle.reload.grace?
      assert_equal 90, @account.reload.balance
      assert_equal 1, polls.count
    end
  end

  def test_waiting_for_the_refund_account_cannot_extend_the_reversal_deadline
    with_feature do
      cycle = renew_automatically
      test = self
      Account.stub_any_instance(:lock!, proc { test.travel_to cycle.cancellation_deadline_at }) do
        assert_no_difference ['AccountActivity.count', 'Notification.count'] do
          assert_command_error(change_preference(reverse_cycle_id: cycle.uuid), 2304)
        end
      end
      assert cycle.reload.grace?
      assert @domain.reload.auto_renew?
      assert_equal @expiry.advance(years: 1), @domain.valid_to
      assert_equal 90, @account.reload.balance
    end
  end
end
