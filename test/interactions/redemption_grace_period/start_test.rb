require 'test_helper'

class StartTest < ActiveSupport::TestCase

  setup do
    @domain = domains(:shop)
    @domain.update(outzone_time: Time.zone.now - 1.day)
  end

  def test_sets_server_hold
    DomainCron.start_redemption_grace_period

    @domain.reload
    assert @domain.statuses.include?(DomainStatus::SERVER_HOLD)
  end

  def test_doesnt_sets_server_hold_if_not_outzone
    @domain.update(outzone_time: nil)
    @domain.reload
    DomainCron.start_redemption_grace_period

    @domain.reload
    assert_not @domain.statuses.include?(DomainStatus::SERVER_HOLD)
  end
end
