require 'test_helper'

class DomainAutoRenewTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    travel_to Time.zone.parse('2027-03-01 12:00:00')
  end

  def test_auto_renew_is_disabled_by_default
    assert_not Domain.new.auto_renew?
    assert_not @domain.auto_renew?
  end

  def test_current_cycle_is_the_latest_by_original_expiry
    old_cycle = create_cycle(@domain, DomainAutoRenewal::COMPLETED,
                             original_expire_at: 1.year.ago)
    current_cycle = create_cycle(@domain, DomainAutoRenewal::GRACE)

    assert_equal current_cycle, @domain.current_auto_renewal
    assert_not_equal old_cycle, @domain.current_auto_renewal
  end

  def test_rgp_status_is_derived_from_active_grace_without_changing_domain_statuses
    assert_nil @domain.current_auto_renewal
    assert_not @domain.auto_renew_grace_active?
    assert_empty @domain.rgp_statuses
    cycle = create_cycle(@domain, DomainAutoRenewal::GRACE)
    original_statuses = @domain.statuses.dup

    assert @domain.auto_renew_grace_active?
    assert_equal ['autoRenewPeriod'], @domain.rgp_statuses
    assert_equal original_statuses, @domain.statuses

    travel_to cycle.cancellation_deadline_at
    assert_not @domain.auto_renew_grace_active?
    assert_empty @domain.rgp_statuses
  end

  def test_rgp_status_is_absent_for_every_non_grace_state
    cycle = create_cycle(@domain, DomainAutoRenewal::AWAITING_FUNDS)
    (DomainAutoRenewal::STATES - [DomainAutoRenewal::GRACE]).each do |state|
      cycle.update!(state: state)
      assert_empty @domain.rgp_statuses
    end
  end

  def test_grace_and_funding_retry_filters_select_matching_domains_without_duplicates
    create_cycle(@domain, DomainAutoRenewal::COMPLETED, original_expire_at: 1.year.ago)
    create_cycle(@domain, DomainAutoRenewal::GRACE)
    retry_domain = domains(:airport)
    create_cycle(retry_domain, DomainAutoRenewal::AWAITING_FUNDS)
    create_cycle(domains(:library), DomainAutoRenewal::GRACE, cancellation_deadline_at: Time.zone.now)
    create_cycle(domains(:metro), DomainAutoRenewal::COMPLETED)

    assert_equal [@domain.id], Domain.auto_renew_grace.ids
    assert_equal [retry_domain.id], Domain.auto_renew_funding_retry.ids
    assert_equal Domain.count, Domain.auto_renew_grace(false).count
    assert_equal Domain.count, Domain.auto_renew_funding_retry(false).count
    assert_equal [@domain.id], Domain.ransack(auto_renew_grace: true).result.ids
    assert_equal [retry_domain.id], Domain.ransack(auto_renew_funding_retry: true).result.ids
    assert_equal Domain.count, Domain.ransack(auto_renew_grace: false).result.count
    assert_equal Domain.count, Domain.ransack(auto_renew_funding_retry: false).result.count
    assert_empty Domain.where(id: retry_domain.id).auto_renew_grace
    assert_equal 1, Domain.auto_renew_grace.count
  end

  def test_preference_is_ransackable
    @domain.update!(auto_renew: true)

    assert_includes Domain.ransackable_attributes, 'auto_renew'
    assert_equal [@domain.id], Domain.ransack(auto_renew_eq: true).result.ids
    assert_not_includes Domain.ransack(auto_renew_eq: false).result, @domain
  end

  def test_transfer_disables_auto_renew
    @domain.update!(auto_renew: true)
    @domain.transfer(registrars(:goodnames))

    assert_equal registrars(:goodnames), @domain.reload.registrar
    assert_not @domain.auto_renew?
  end

  def test_direct_sponsor_change_disables_auto_renew_even_without_validation
    @domain.update!(auto_renew: true)
    @domain.registrar = registrars(:goodnames)
    @domain.save!(validate: false)

    assert_not @domain.reload.auto_renew?
  end

  def test_non_sponsor_changes_keep_auto_renew_enabled
    @domain.update!(auto_renew: true)
    @domain.registrar = registrars(:bestnames)
    @domain.transfer_code = 'new-transfer-code'
    @domain.save!

    assert @domain.reload.auto_renew?
  end

  def test_initial_sponsor_assignment_keeps_auto_renew_enabled
    domain = @domain.dup
    domain.name = domain.name_dirty = domain.name_puny = 'auto-renew.test'
    domain.uuid = SecureRandom.uuid
    domain.auto_renew = true
    domain.save!(validate: false)

    assert domain.reload.auto_renew?
  end

  def test_assigning_renewal_expiry_clears_expiry_and_pending_delete_without_saving
    original_expiry = @domain.valid_to
    @domain.statuses = [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD,
                        DomainStatus::PENDING_DELETE, DomainStatus::PENDING_DELETE_CONFIRMATION,
                        DomainStatus::SERVER_UPDATE_PROHIBITED]
    @domain.status_notes['serverHold'] = ''
    new_expiry = original_expiry.advance(years: 1)

    @domain.assign_renewal_expiry(new_expiry)

    assert_equal new_expiry, @domain.valid_to
    assert_nil @domain.outzone_at
    assert_nil @domain.delete_date
    assert_equal 1, @domain.period
    assert_equal 'y', @domain.period_unit
    assert_equal [DomainStatus::SERVER_UPDATE_PROHIBITED], @domain.statuses
    assert_equal original_expiry, Domain.find(@domain.id).valid_to
  end

  def test_assigning_renewal_expiry_preserves_noted_hold_and_requested_period
    @domain.statuses = [DomainStatus::SERVER_HOLD]
    @domain.status_notes['serverHold'] = 'Administrative hold'
    new_expiry = @domain.valid_to.advance(months: 3)

    @domain.assign_renewal_expiry(new_expiry, period: 3, unit: 'm')

    assert_equal new_expiry, @domain.valid_to
    assert_includes @domain.statuses, DomainStatus::SERVER_HOLD
    assert_equal 'Administrative hold', @domain.status_notes['serverHold']
    assert_equal 3, @domain.period
    assert_equal 'm', @domain.period_unit
  end

  def test_pricelist_selects_the_tariff_at_the_requested_time
    historical = billing_prices(:renew_one_year)
    historical.update!(valid_from: Time.zone.parse('2026-01-01'),
                       valid_to: Time.zone.parse('2026-12-31'))
    current = historical.dup
    current.update!(price_cents: 1200, valid_from: Time.zone.parse('2027-01-01'), valid_to: nil)

    assert_equal historical, @domain.pricelist('renew', 1, 'y', at: Time.zone.parse('2026-06-01'))
    assert_equal current, @domain.pricelist('renew', 1, 'y')
  end

  private

  def create_cycle(domain, state, **attributes)
    DomainAutoRenewal.create!({
      domain: domain,
      domain_name: domain.name,
      registrar: domain.registrar,
      account: domain.registrar.cash_account,
      state: state,
      original_expire_at: Time.zone.now,
      cancellation_deadline_at: Time.zone.now.advance(days: 15)
    }.merge(attributes))
  end
end
