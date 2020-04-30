require 'test_helper'

class DisputedDomainTest < ActiveSupport::TestCase
  setup do
    @dispute = disputes(:active)
  end

  def test_fixture_is_valid
    assert @dispute.valid?
  end

  def test_can_be_closed_by_domain_name
    travel_to Time.zone.parse('2010-10-05')

    Dispute.close_by_domain(@dispute.domain_name)
    @dispute.reload

    assert @dispute.closed
  end

  def test_syncs_password_to_reserved
    dispute = Dispute.new(domain_name: 'reserved.test', starts_at: Time.zone.today, password: 'disputepw')
    dispute.save
    dispute.reload
    assert_equal dispute.password, ReservedDomain.find_by(name: dispute.domain_name).password
  end

  def test_domain_name_zone_is_validated
    dispute = Dispute.new(domain_name: 'correct.test', starts_at: Time.zone.today)
    assert dispute.valid?

    dispute.domain_name = 'zone.is.unrecognized.test'
    assert_not dispute.valid?
  end

  def test_dispute_can_not_be_created_if_another_active_is_present
    dispute = Dispute.new(domain_name: @dispute.domain_name,
                          starts_at: @dispute.starts_at + 1.day)
    assert_not dispute.valid?
  end

  def test_expires_at_date_is_appended_automatically
    dispute = Dispute.new(domain_name: 'random.test', starts_at: Time.zone.today)
    assert dispute.valid?
    assert_equal dispute.expires_at, dispute.starts_at + 3.years
  end

  def test_starts_at_must_be_present
    dispute = Dispute.new(domain_name: 'random.test')
    assert_not dispute.valid?
  end
end
