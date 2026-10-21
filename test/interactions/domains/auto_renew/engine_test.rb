require_relative 'test_case'

class AutoRenewEngineTest < AutoRenewTestCase
  def test_open_is_idempotent_and_captures_the_payer_and_calendar_deadline
    with_feature do
      cycle = open_cycle
      assert_no_difference 'DomainAutoRenewal.count' do
        assert_equal cycle, open_cycle
      end
      assert_equal @registrar, cycle.registrar
      assert_equal @account, cycle.account
      assert_equal @expiry, cycle.original_expire_at
      assert_equal @expiry.advance(days: 15), cycle.cancellation_deadline_at
      assert_equal 'fundingRetry', cycle.protocol_state
      assert cycle.uuid.present?
      assert_equal 0, polls.count
    end
  end

  def test_open_requires_expiry_preference_and_feature
    with_feature do
      travel_to @expiry - 1.second
      assert_nil open_cycle
      travel_to @expiry
      @domain.update_columns(auto_renew: false)
      assert_nil open_cycle
      @domain.update_columns(auto_renew: true)
      with_feature(false) { assert_nil open_cycle }
      assert_equal 0, @domain.auto_renewals.count
    end
  end

  def test_manual_renewal_rejects_a_request_loaded_before_automatic_renewal
    with_feature do
      requested_domain = Epp::Domain.find(@domain.id)
      cycle = renew_automatically
      balance = @account.reload.balance

      assert_no_difference 'AccountActivity.count' do
        outcome = Domains::BulkRenew::SingleDomainRenew.run(
          domain: requested_domain, registrar: @registrar, period: 1, unit: 'y'
        )
        assert_not outcome.valid?
        message = I18n.t('auto_renew.errors.expiry_changed')
        assert_includes outcome.errors[:domain], message
        assert requested_domain.errors.any? { |error| error.options[:code] == 2304 && error.options[:msg] == message }
      end
      assert_equal balance, @account.reload.balance
      assert_equal cycle.renewed_expire_at, @domain.reload.valid_to
    end
  end

  def test_manual_renewal_retries_only_transaction_conflicts_at_most_three_times
    interaction = Domains::BulkRenew::SingleDomainRenew.new(
      domain: Epp::Domain.find(@domain.id), registrar: @registrar, period: 1, unit: 'y'
    )
    [ActiveRecord::SerializationFailure, ActiveRecord::Deadlocked, ActiveRecord::StatementInvalid].each do |error_class|
      attempts = 0
      assert_raises(error_class) do
        interaction.in_transaction_with_retries do
          attempts += 1
          raise error_class, 'transaction failed'
        end
      end
      assert_equal(error_class == ActiveRecord::StatementInvalid ? 1 : 3, attempts)
    end
  end

  def test_missing_cycle_only_delays_ordinary_expiry_before_the_cancellation_deadline
    with_feature do
      deadline = DomainAutoRenewal.cancellation_deadline_for(@expiry)
      travel_to deadline - 1.second
      Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
      assert_not_includes @domain.reload.statuses, DomainStatus::EXPIRED
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date

      [deadline, deadline + 1.second].each do |at|
        @domain.update_columns(statuses: [], outzone_at: nil, delete_date: nil)
        travel_to at
        Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
        assert_empty @domain.auto_renewals
        assert_includes @domain.reload.statuses, DomainStatus::EXPIRED
        assert_equal @expiry + Domain.expire_warning_period, @domain.outzone_at
        assert_equal (@domain.outzone_at + Domain.redemption_grace_period).to_date, @domain.delete_date
      end
    end
  end

  def test_success_debits_once_and_clears_expiry_fields_and_unnoted_hold
    with_feature do
      @domain.update_columns(statuses: [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD],
                             outzone_at: @expiry.advance(days: 15), delete_date: @expiry.advance(days: 45))
      cycle = open_cycle
      assert_difference -> { polls.count }, 1 do
        assert_difference 'AccountActivity.count', 1 do
          attempt(cycle)
          attempt(cycle)
          DomainCron.process_auto_renewals
        end
      end
      assert_equal 90, @account.reload.balance
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date
      assert_not_includes @domain.statuses, DomainStatus::EXPIRED
      assert_not_includes @domain.statuses, DomainStatus::SERVER_HOLD
      assert @domain.auto_renew?
      assert cycle.reload.grace?
      assert_equal AccountActivity::RENEW, cycle.charge_activity.activity_type
      assert_equal @price.id, cycle.price_id
      assert_equal @price.id, cycle.charge_activity.price_id
      assert_equal(-10, cycle.charge_activity.sum)
      assert_equal 'renewed', polls.order(:id).last.event
      assert_equal 1, cycle.attempts_count
      assert_equal @registrar.id, polls.first.registrar_id
      assert_equal cycle.id, polls.first.attached_obj_id
    end
  end

  def test_price_is_selected_at_original_expiry_when_a_newer_tariff_starts_later
    with_feature do
      @price.update!(valid_to: @expiry.end_of_day)
      newer = Billing::Price.create!(zone: @price.zone, operation_category: 'renew', duration: 1.year,
                                    price_cents: 2500, valid_from: @expiry.advance(days: 1).beginning_of_day)
      cycle = open_cycle
      travel_to @expiry.advance(days: 3)
      assert_equal newer, @domain.pricelist('renew', 1, 'y')
      attempt(cycle)
      assert_equal @price.id, cycle.reload.price_id
      assert_equal(-10, cycle.charge_activity.sum)
      assert_equal 90, @account.reload.balance
    end
  end

  def test_insufficient_funds_retries_once_warns_then_late_success_keeps_deadline
    with_feature do
      @account.update!(balance: 0)
      cycle = open_cycle
      deadline = cycle.cancellation_deadline_at
      2.times { attempt(cycle) }
      assert_equal 1, polls.count
      assert_equal 'fundingWarning', polls.order(:id).last.event
      warning = polls.order(:id).last
      assert_equal 2, cycle.attempts_count
      assert_nil cycle.charge_activity
      assert_equal @expiry, @domain.reload.valid_to

      Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
      travel_to @expiry.advance(days: 10)
      @account.account_activities.create!(sum: 20, currency: 'EUR', activity_type: AccountActivity::ADD_CREDIT)
      attempt(cycle)
      assert cycle.reload.grace?
      assert_equal deadline, cycle.cancellation_deadline_at
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date
      assert_not_includes @domain.statuses, DomainStatus::EXPIRED
      assert_equal 10, @account.reload.balance
      assert_equal 2, polls.count
      assert_equal 'fundingWarning', warning.reload.event
      assert_equal 'renewed', polls.order(:id).last.event
      assert_equal 3, cycle.attempts_count
    end
  end

  def test_unpaid_deadline_keeps_preference_and_retries_with_exactly_one_overdue_notice
    with_feature do
      @account.update!(balance: 0)
      cycle = open_cycle
      attempt(cycle)
      deadline = cycle.cancellation_deadline_at
      travel_to deadline
      assert_difference -> { polls.count }, 1 do
        3.times do
          DomainCron.process_auto_renewals
          travel_to Time.zone.now + 1.day
        end
      end
      assert cycle.reload.awaiting_funds?
      assert_equal 'fundingRetry', cycle.protocol_state
      assert @domain.reload.auto_renew?
      assert_nil cycle.closed_at
      assert_equal deadline, cycle.overdue_notice_sent_at
      assert_equal 4, cycle.attempts_count
      assert_equal 1, polls.where(event: 'renewalOverdue').count
      assert_equal @expiry, @domain.valid_to
      assert_equal I18n.t('auto_renew.notifications.renewal_overdue', domain: @domain.name,
                          deadline: deadline.iso8601, cycle_id: cycle.uuid,
                          reason: I18n.t('auto_renew.failure_reasons.insufficient_funds')),
                   polls.find_by!(event: 'renewalOverdue').text
    end
  end

  [0, 2.days].each do |delay|
    define_method("test_top_up_#{delay}_seconds_after_deadline_completes_and_restores_zone_without_reversal") do
      with_feature do
        @account.update!(balance: 0)
        cycle = open_cycle
        attempt(cycle)
        travel_to cycle.cancellation_deadline_at + delay
        Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
        @domain.reload.update_columns(statuses: [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD])
        @account.account_activities.create!(sum: 20, currency: 'EUR', activity_type: AccountActivity::ADD_CREDIT)
        DomainCron.process_auto_renewals
        assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
        assert_equal Time.zone.now, cycle.renewed_at
        assert_equal cycle.renewed_at, cycle.closed_at
        assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
        assert @domain.auto_renew?
        assert_nil @domain.outzone_at
        assert_nil @domain.delete_date
        assert_not_includes @domain.statuses, DomainStatus::EXPIRED
        assert_not_includes @domain.statuses, DomainStatus::SERVER_HOLD
        assert_empty @domain.rgp_statuses
        assert_equal 10, @account.reload.balance
        assert_not cycle.reversible?
        assert_no_difference ['AccountActivity.count', 'Notification.count'] do
          assert_command_error(change_preference(reverse_cycle_id: cycle.uuid), 2304)
          DomainCron.process_auto_renewals
        end
        assert_equal 'renewed', polls.order(:id).last.event
        assert_equal I18n.t('auto_renew.notifications.renewed_after_deadline', domain: @domain.name,
                            expire_date: cycle.renewed_expire_at.iso8601, amount: '10.00', cycle_id: cycle.uuid),
                     polls.order(:id).last.text
      end
    end
  end

  [DomainStatus::SERVER_RENEW_PROHIBITED, DomainStatus::PENDING_DELETE, DomainStatus::PENDING_UPDATE].each do |status|
    define_method("test_#{status}_keeps_retrying_past_deadline_and_succeeds_when_lifted") do
      with_feature do
        @domain.update_columns(statuses: [status])
        cycle = open_cycle
        2.times { attempt(cycle) }
        assert_equal DomainAutoRenewal::RENEW_PROHIBITED, cycle.reload.failure_reason
        assert_equal 'renewProhibited', polls.order(:id).last.event
        assert_equal 1, polls.count
        travel_to cycle.cancellation_deadline_at + 1.day
        3.times { DomainCron.process_auto_renewals }
        assert cycle.reload.awaiting_funds?
        assert @domain.reload.auto_renew?
        assert_equal 5, cycle.attempts_count
        assert_equal 100, @account.reload.balance
        assert_equal 1, polls.where(event: 'renewalOverdue').count
        assert_equal 2, polls.count
        assert_includes polls.find_by!(event: 'renewalOverdue').text,
                        I18n.t('auto_renew.failure_reasons.renew_prohibited')
        @domain.update_columns(statuses: [])
        DomainCron.process_auto_renewals
        assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
        assert_nil cycle.failure_reason
        assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
        assert_equal 90, @account.reload.balance
        assert_equal 3, polls.count
      end
    end
  end

  def test_enabling_preference_on_an_out_of_zone_domain_opens_and_renews_a_cycle
    with_feature do
      @domain.update_columns(auto_renew: false)
      travel_to @expiry.advance(days: 20)
      Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
      @domain.reload.update_columns(statuses: [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD])
      assert @domain.outzone_at < Time.zone.now
      assert_empty @domain.auto_renewals
      assert change_preference(enabled: true).valid?
      DomainCron.process_auto_renewals
      assert_equal 1, @domain.auto_renewals.count
      cycle = @domain.auto_renewals.first
      assert_equal DomainAutoRenewal::COMPLETED, cycle.state
      assert_equal @expiry, cycle.original_expire_at
      assert_equal @expiry.advance(days: 15), cycle.cancellation_deadline_at
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert @domain.auto_renew?
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date
      assert_not_includes @domain.statuses, DomainStatus::EXPIRED
      assert_not_includes @domain.statuses, DomainStatus::SERVER_HOLD
      assert_empty @domain.rgp_statuses
      assert_no_difference ['DomainAutoRenewal.count', 'AccountActivity.count', 'Notification.count'] do
        DomainCron.process_auto_renewals
      end
    end
  end

  [0, 16.days].each do |delay|
    define_method("test_domain_deletion_#{delay}_seconds_after_expiry_cancels_on_next_sweep") do
      with_feature do
        cycle = open_cycle
        travel_to @expiry + delay
        @domain.destroy!
        assert_nil cycle.reload.domain_id
        assert_no_difference ['AccountActivity.count', 'Notification.count'] do
          DomainCron.process_auto_renewals
        end
        assert_equal DomainAutoRenewal::CANCELLED, cycle.reload.state
        assert_equal Time.zone.now, cycle.closed_at
      end
    end
  end

  def test_overdue_notification_failure_rolls_back_its_deduplication_timestamp
    with_feature do
      @account.update!(balance: 0)
      cycle = open_cycle
      attempt(cycle)
      travel_to cycle.cancellation_deadline_at
      Notification.stub_any_instance(:save!, proc { raise 'poll failed' }) do
        assert_raises RuntimeError do
          Domains::AutoRenew::CloseCycle.run!(cycle: cycle)
        end
      end
      assert_nil cycle.reload.overdue_notice_sent_at
      assert cycle.awaiting_funds?
      assert @domain.reload.auto_renew?
      DomainCron.process_auto_renewals
      assert_equal 1, polls.where(event: 'renewalOverdue').count
    end
  end

  def test_lifting_a_block_allows_a_single_paid_renewal
    with_feature do
      @domain.update_columns(statuses: [DomainStatus::SERVER_RENEW_PROHIBITED])
      cycle = open_cycle
      attempt(cycle)
      @domain.update_columns(statuses: [])
      attempt(cycle)
      assert cycle.reload.grace?
      assert_nil cycle.failure_reason
      assert_equal 90, @account.reload.balance
      assert_equal 2, polls.count
    end
  end

  def test_missing_price_is_retried_with_one_blocked_warning
    with_feature do
      @price.update!(valid_to: @expiry.advance(days: -1))
      cycle = open_cycle
      2.times { attempt(cycle) }
      assert_equal DomainAutoRenewal::MISSING_PRICE, cycle.reload.failure_reason
      assert_equal 'renewProhibited', polls.order(:id).last.event
      assert_equal 1, polls.count
      assert_equal 100, @account.reload.balance
      @price.update!(valid_to: nil)
      attempt(cycle)
      assert cycle.reload.grace?
    end
  end

  def test_manual_renewal_cancels_an_awaiting_cycle_without_charging
    with_feature do
      cycle = open_cycle
      @domain.assign_renewal_expiry(@expiry.advance(years: 1))
      @domain.save!(validate: false)
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        attempt(cycle)
      end
      assert_equal DomainAutoRenewal::CANCELLED, cycle.reload.state
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_equal 100, @account.reload.balance
    end
  end

  def test_grace_end_completes_without_money_preference_or_poll_changes
    with_feature do
      cycle = renew_automatically
      travel_to cycle.cancellation_deadline_at
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        2.times { DomainCron.process_auto_renewals }
      end
      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      assert_equal 'renewed', polls.order(:id).last.event
      assert @domain.reload.auto_renew?
      assert_equal @expiry.advance(years: 1), @domain.valid_to
      assert_equal 90, @account.reload.balance
    end
  end

  def test_feature_off_still_attempts_and_closes_existing_cycles
    with_feature do
      cycle = open_cycle
      with_feature(false) do
        DomainCron.process_auto_renewals
        assert cycle.reload.grace?
        travel_to cycle.cancellation_deadline_at
        DomainCron.process_auto_renewals
        assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      end
    end
  end

  def test_sweep_isolates_failures_and_sets_papertrail_actor
    with_feature do
      broken = domains(:airport)
      broken.update_columns(auto_renew: true, valid_to: @expiry)
      original_run = Domains::AutoRenew::OpenCycle.method(:run!)
      replacement = lambda do |domain:|
        raise 'one broken domain' if domain.id == broken.id
        original_run.call(domain: domain)
      end
      Domains::AutoRenew::OpenCycle.stub(:run!, replacement) { DomainCron.process_auto_renewals }
      assert_equal 1, @domain.auto_renewals.count
      cycle = @domain.auto_renewals.first
      assert cycle.grace?
      assert_equal 'cron - Domains::AutoRenew::Start', cycle.creator_str
      assert_equal 'cron - Domains::AutoRenew::Start', @domain.reload.updator_str
      assert_empty broken.auto_renewals
    end
  end

  def test_renewal_rolls_back_the_debit_and_expiry_if_poll_creation_fails
    with_feature do
      cycle = open_cycle
      Notification.stub_any_instance(:save!, proc { raise 'poll failed' }) do
        assert_raises RuntimeError do
          attempt(cycle)
        end
      end
      assert_equal 100, @account.reload.balance
      assert_equal @expiry, @domain.reload.valid_to
      assert cycle.reload.awaiting_funds?
      assert_nil cycle.charge_activity_id
      assert_equal 0, cycle.attempts_count
      assert_equal 0, polls.count
    end
  end

  def test_only_serialization_and_deadlock_failures_are_retried_at_most_three_times
    with_feature do
      [ActiveRecord::SerializationFailure, ActiveRecord::Deadlocked, RuntimeError].each do |error_class|
        attempts = 0
        @domain.stub(:reload, lambda { |**_options| attempts += 1; raise error_class, 'retry test' }) do
          assert_raises(error_class) { open_cycle }
        end
        assert_equal(error_class == RuntimeError ? 1 : 3, attempts)
      end
      assert_equal 0, @domain.auto_renewals.count
    end
  end

  def test_leap_day_renewal_uses_a_calendar_year
    with_feature do
      leap_day = Time.zone.parse('2028-02-29 12:00:00')
      travel_to leap_day
      @domain.update_columns(valid_to: leap_day)
      cycle = renew_automatically
      assert_equal Time.zone.parse('2029-02-28 12:00:00'), @domain.reload.valid_to
      assert_equal Time.zone.parse('2028-03-15 12:00:00'), cycle.cancellation_deadline_at
    end
  end

  def test_crossing_the_deadline_while_waiting_for_the_account_lock_completes_without_grace
    with_feature do
      cycle = open_cycle
      account = cycle.account
      original_lock = account.method(:lock!)
      replacement = proc do
        original_lock.call
        travel_to cycle.cancellation_deadline_at
      end
      cycle.stub(:account, account) do
        account.stub(:lock!, replacement) do
          assert_difference ['AccountActivity.count', 'Notification.count'], 1 do
            attempt(cycle)
          end
        end
      end
      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state
      assert_equal Time.zone.now, cycle.closed_at
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_equal 90, @account.reload.balance
    end
  end

  def test_cash_account_replacement_cannot_charge_an_account_other_than_the_cycle_account
    with_feature do
      cycle = open_cycle
      @account.update!(account_type: 'old_cash')
      replacement = Account.create!(registrar: @registrar, account_type: Account::CASH, balance: 100, currency: 'EUR')
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        assert_raises(ActiveRecord::RecordNotFound) { attempt(cycle) }
      end
      assert cycle.reload.awaiting_funds?
      assert_equal 100, @account.reload.balance
      assert_equal 100, replacement.reload.balance
    end
  end
end
