require 'test_helper'

class DomainAutoRenewalTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    @original_expire_at = Time.zone.parse('2028-02-29 12:30:00')
    @cycle = DomainAutoRenewal.new(
      domain: @domain,
      domain_name: @domain.name,
      registrar: registrars(:bestnames),
      account: accounts(:cash),
      original_expire_at: @original_expire_at,
      cancellation_deadline_at: DomainAutoRenewal.cancellation_deadline_for(@original_expire_at)
    )
  end

  def test_validations_and_optional_associations
    assert @cycle.valid?, @cycle.errors.full_messages.join(', ')
    @cycle.domain = nil
    assert @cycle.valid?

    @cycle.state = 'unknown'
    @cycle.domain_name = nil
    @cycle.original_expire_at = nil
    @cycle.cancellation_deadline_at = nil
    assert_not @cycle.valid?
    %i[state domain_name original_expire_at cancellation_deadline_at].each do |attribute|
      assert @cycle.errors[attribute].present?
    end
  end

  def test_deadline_is_fifteen_calendar_days_after_leap_day
    assert_equal Time.zone.parse('2028-03-15 12:30:00'), @cycle.cancellation_deadline_at
  end

  def test_deadline_preserves_local_time_across_daylight_saving_changes
    Time.use_zone('Europe/Tallinn') do
      ['2027-03-20 12:30:00', '2027-10-20 12:30:00'].each do |date|
        original = Time.zone.parse(date)
        deadline = DomainAutoRenewal.cancellation_deadline_for(original)

        assert_equal original.advance(days: 15), deadline
        assert_equal original.hour, deadline.hour
        assert_not_equal original.utc_offset, deadline.utc_offset
        assert_not_equal original + 360.hours, deadline
      end
    end
  end

  def test_state_predicates_and_protocol_states
    travel_to @original_expire_at
    protocol_states = {
      DomainAutoRenewal::AWAITING_FUNDS => 'fundingRetry',
      DomainAutoRenewal::GRACE => 'autoRenewPeriod',
      DomainAutoRenewal::COMPLETED => 'completed',
      DomainAutoRenewal::REVERSED => 'reversed',
      DomainAutoRenewal::FAILED => 'failed',
      DomainAutoRenewal::CANCELLED => 'cancelled'
    }

    protocol_states.each do |state, protocol_state|
      @cycle.state = state
      assert_equal protocol_state, @cycle.protocol_state
      assert_equal DomainAutoRenewal::OPEN_STATES.include?(state), @cycle.open?
      assert_equal !@cycle.open?, @cycle.terminal?
      assert_equal state == DomainAutoRenewal::AWAITING_FUNDS, @cycle.awaiting_funds?
      assert_equal state == DomainAutoRenewal::GRACE, @cycle.grace?
      assert_equal state == DomainAutoRenewal::REVERSED, @cycle.reversed?
      assert_equal @cycle.grace?, @cycle.grace_active?
      assert_equal @cycle.grace_active?, @cycle.reversible?
    end
  end

  def test_grace_ends_at_the_deadline_even_before_cycle_is_closed
    @cycle.state = DomainAutoRenewal::GRACE
    deadline = @cycle.cancellation_deadline_at

    assert @cycle.grace_active?(deadline - 1.second)
    assert @cycle.reversible?(deadline - 1.second)
    [deadline, deadline + 1.second].each do |at|
      assert_not @cycle.grace_active?(at)
      assert_not @cycle.reversible?(at)
      assert_equal 'completed', @cycle.protocol_state(at)
    end
    assert @cycle.open?
  end

  def test_protocol_json_contains_cycle_identity_and_timestamps
    @cycle.state = DomainAutoRenewal::GRACE
    @cycle.renewed_expire_at = @original_expire_at.advance(years: 1)
    @cycle.attempts_count = 3
    @cycle.save!
    @cycle.reload

    assert_equal({
      id: @cycle.uuid,
      state: 'autoRenewPeriod',
      original_expire_time: @original_expire_at.iso8601,
      expire_time: @cycle.renewed_expire_at.iso8601,
      cancellation_deadline: @cycle.cancellation_deadline_at.iso8601,
      attempts: 3
    }, @cycle.as_protocol_json(@original_expire_at))
    assert @cycle.uuid.present?
    assert_equal 'completed', @cycle.as_protocol_json(@cycle.cancellation_deadline_at)[:state]
  end

  def test_protocol_json_has_no_expiry_before_renewal
    travel_to @original_expire_at
    assert_nil @cycle.as_protocol_json[:expire_time]
    assert_equal 'fundingRetry', @cycle.as_protocol_json[:state]
    assert_equal 0, @cycle.as_protocol_json[:attempts]
  end

  def test_scopes_select_only_the_relevant_states_and_due_open_cycles
    travel_to @original_expire_at
    @cycle.save!
    grace = @cycle.dup
    grace.uuid = SecureRandom.uuid
    grace.domain = domains(:airport)
    grace.state = DomainAutoRenewal::GRACE
    grace.cancellation_deadline_at = Time.zone.now
    grace.save!
    completed = @cycle.dup
    completed.uuid = SecureRandom.uuid
    completed.domain = domains(:library)
    completed.state = DomainAutoRenewal::COMPLETED
    completed.cancellation_deadline_at = 1.second.ago
    completed.save!

    assert_equal [@cycle.id, grace.id].sort, DomainAutoRenewal.open_cycles.ids.sort
    assert_equal [@cycle.id], DomainAutoRenewal.awaiting_funds.ids
    assert_equal [@cycle.id], DomainAutoRenewal.due_for_attempt.ids
    @cycle.update!(last_attempt_at: Time.zone.now)
    assert_empty DomainAutoRenewal.due_for_attempt
    assert_empty DomainAutoRenewal.due_for_attempt(Time.zone.now + 23.hours)
    assert_equal [@cycle.id], DomainAutoRenewal.due_for_attempt(Time.zone.now + 24.hours).ids
    assert_empty DomainAutoRenewal.due_for_attempt(@cycle.cancellation_deadline_at)
    @cycle.update!(state: DomainAutoRenewal::FAILED)
    assert_empty DomainAutoRenewal.due_for_attempt(Time.zone.now + 24.hours)
    @cycle.update!(state: DomainAutoRenewal::AWAITING_FUNDS)
    assert_equal [grace.id], DomainAutoRenewal.in_grace.ids
    assert_equal [grace.id], DomainAutoRenewal.due_for_closing.ids
    assert_empty DomainAutoRenewal.due_for_closing(Time.zone.now - 1.second)
    assert_equal [@cycle.id, grace.id].sort,
                 DomainAutoRenewal.due_for_closing(@cycle.cancellation_deadline_at).ids.sort
  end

  def test_database_rejects_two_open_cycles_for_one_domain
    @cycle.save!
    duplicate = @cycle.dup
    duplicate.uuid = SecureRandom.uuid
    duplicate.state = DomainAutoRenewal::GRACE
    duplicate.original_expire_at = @original_expire_at.advance(years: 1)

    assert_raises ActiveRecord::RecordNotUnique do
      DomainAutoRenewal.transaction(requires_new: true) { duplicate.save! }
    end
  end

  def test_database_rejects_another_cycle_for_the_same_original_expiry
    @cycle.state = DomainAutoRenewal::COMPLETED
    @cycle.save!
    duplicate = @cycle.dup
    duplicate.uuid = SecureRandom.uuid
    duplicate.state = DomainAutoRenewal::CANCELLED

    assert_raises ActiveRecord::RecordNotUnique do
      DomainAutoRenewal.transaction(requires_new: true) { duplicate.save! }
    end
  end

  def test_database_rejects_unknown_states_even_without_validation
    @cycle.state = 'unknown'

    assert_raises ActiveRecord::StatementInvalid do
      DomainAutoRenewal.transaction(requires_new: true) { @cycle.save!(validate: false) }
    end
  end

  def test_failed_cycle_allows_a_new_cycle_for_a_later_expiry
    @cycle.state = DomainAutoRenewal::FAILED
    @cycle.save!
    next_cycle = @cycle.dup
    next_cycle.uuid = SecureRandom.uuid
    next_cycle.state = DomainAutoRenewal::AWAITING_FUNDS
    next_cycle.original_expire_at = @original_expire_at.advance(years: 1)
    next_cycle.cancellation_deadline_at = DomainAutoRenewal.cancellation_deadline_for(next_cycle.original_expire_at)

    assert next_cycle.save!
    assert_equal [next_cycle.id], @domain.auto_renewals.open_cycles.ids
  end

  def test_cycle_changes_are_versioned_with_attribution
    PaperTrail.request(whodunnit: 'auto-renew-test') do
      @cycle.save!
      @cycle.update!(state: DomainAutoRenewal::GRACE)
    end

    assert_equal 'auto-renew-test', @cycle.creator_str
    assert_equal 'auto-renew-test', @cycle.updator_str
    version = @cycle.versions.last
    assert_instance_of Version::DomainAutoRenewalVersion, version
    assert_equal 'update', version.event
    assert_equal 'auto-renew-test', version.whodunnit
    assert_equal [DomainAutoRenewal::AWAITING_FUNDS, DomainAutoRenewal::GRACE], version.object_changes['state']
  end

  def test_cycles_survive_domain_deletion
    @cycle.save!
    @domain.destroy!

    assert_nil @cycle.reload.domain_id
    assert_equal 'shop.test', @cycle.domain_name
  end
end
