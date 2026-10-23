require 'test_helper'
require 'serializers/repp/domain'

class SerializersReppDomainTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:airport)
  end

  def test_returns_status_notes
    status_notes = { 'serverForceDelete' => '`@internet2.ee' }
    @domain.update!(statuses: %w[serverForceDelete], status_notes: status_notes)
    @serializer = Serializers::Repp::Domain.new(@domain)
    @json = @serializer.to_json

    assert_equal(status_notes, @json[:statuses])
  end

  def test_auto_renew_defaults_are_included_in_full_and_simple_forms
    [true, false].each do |simplify|
      json = Serializers::Repp::Domain.new(@domain, simplify: simplify).to_json

      assert_equal({ enabled: false, cycle: nil }, json[:auto_renew])
      assert_equal [], json[:rgp_statuses]
    end
  end

  def test_preference_and_cycle_are_sponsor_only_in_full_and_simple_forms
    travel_to Time.zone.local(2027, 3, 5, 12)
    @domain.update_columns(auto_renew: true)
    cycle = @domain.auto_renewals.create!(
      domain_name: @domain.name, registrar: @domain.registrar, account: @domain.registrar.cash_account,
      state: DomainAutoRenewal::GRACE, original_expire_at: 1.day.ago,
      renewed_expire_at: 1.day.ago.advance(years: 1), cancellation_deadline_at: 14.days.from_now,
      attempts_count: 2
    )

    [true, false].each do |simplify|
      sponsor = Serializers::Repp::Domain.new(@domain, simplify: simplify).to_json
      non_sponsor = Serializers::Repp::Domain.new(@domain, sponsored: false, simplify: simplify).to_json

      assert_equal({ enabled: true, cycle: cycle.as_protocol_json }, sponsor[:auto_renew])
      refute non_sponsor.key?(:auto_renew)
      assert_equal ['autoRenewPeriod'], sponsor[:rgp_statuses]
      assert_equal sponsor[:rgp_statuses], non_sponsor[:rgp_statuses]
    end

    travel_to cycle.cancellation_deadline_at
    [true, false].each do |simplify|
      json = Serializers::Repp::Domain.new(@domain, simplify: simplify).to_json
      assert_equal [], json[:rgp_statuses]
      assert_equal 'completed', json[:auto_renew][:cycle][:state]
    end
  end
end
