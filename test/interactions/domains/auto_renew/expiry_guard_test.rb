require_relative 'test_case'

class AutoRenewExpiryGuardTest < AutoRenewTestCase
  def test_both_expiry_entry_points_skip_an_opted_in_domain_until_a_cycle_exists
    with_feature do
      Domains::ExpirePeriod::Start.run!
      Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
      assert_not_includes @domain.reload.statuses, DomainStatus::EXPIRED
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date

      open_cycle
      Domains::ExpirePeriod::Start.run!
      assert_includes @domain.reload.statuses, DomainStatus::EXPIRED
      assert_equal @expiry + Domain.expire_warning_period, @domain.outzone_at
      assert_equal (@domain.outzone_at + Domain.redemption_grace_period).to_date, @domain.delete_date
    end
  end

  def test_feature_off_allows_normal_expiry_without_a_cycle
    with_feature(false) do
      Domains::ExpirePeriod::ProcessExpired.run!(domain: @domain)
      assert_includes @domain.reload.statuses, DomainStatus::EXPIRED
      assert @domain.outzone_at.present?
      assert @domain.delete_date.present?
      assert_empty @domain.auto_renewals
    end
  end

  def test_stale_expiry_processing_does_not_undo_successful_automatic_renewal
    with_feature do
      stale_domain = Domain.find(@domain.id)
      renew_automatically
      Domains::ExpirePeriod::ProcessExpired.run!(domain: stale_domain)
      assert_equal @expiry.advance(years: 1), @domain.reload.valid_to
      assert_nil @domain.outzone_at
      assert_nil @domain.delete_date
      assert_not_includes @domain.statuses, DomainStatus::EXPIRED
    end
  end
end
