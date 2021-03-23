require "test_helper"

class DomainExpireEmailJobTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    travel_to Time.zone.parse('2010-08-06')
    @domain.update(valid_to: Time.now - 1.day)
    @domain.reload
    @email = @domain.registrant.email
  end

  def test_domain_expire
    success = DomainExpireEmailJob.run(@domain.id, @email)
    assert success
  end

  def test_domain_expire_with_force_delete
    @domain.update(statuses: [DomainStatus::FORCE_DELETE])
    @domain.reload
    assert_equal ['serverForceDelete'], @domain.statuses

    success = DomainExpireEmailJob.run(@domain.id, @email)
    assert success

    statuses = @domain.statuses
    statuses.delete(DomainStatus::FORCE_DELETE)
    @domain.update(statuses: statuses)
    assert_equal ['ok'], @domain.statuses
  end
end
