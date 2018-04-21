require 'test_helper'

class DomainForceDeleteTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
  end

  def test_schedule_force_delete
    @original_redemption_grace_period = Setting.redemption_grace_period
    Setting.redemption_grace_period = 30
    travel_to Time.zone.parse('2010-07-05 00:00')

    @domain.schedule_force_delete

    assert @domain.force_delete_scheduled?
    assert_equal Time.zone.parse('2010-08-04 03:00'), @domain.force_delete_at

    travel_back
    Setting.redemption_grace_period = @original_redemption_grace_period
  end

  def test_scheduling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete
    assert @domain.force_delete_scheduled?
  end

  def test_cancel_force_delete
    @domain.cancel_force_delete
    assert_not @domain.force_delete_scheduled?
    assert_nil @domain.force_delete_at
  end

  def test_cancelling_force_delete_bypasses_validation
    @domain = domains(:invalid)
    @domain.schedule_force_delete
    @domain.cancel_force_delete
    assert_not @domain.force_delete_scheduled?
  end
end
