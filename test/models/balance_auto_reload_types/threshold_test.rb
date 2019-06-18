require 'test_helper'

class BalanceAutoReloadTypes::ThresholdTest < ActiveSupport::TestCase
  setup do
    @original_min_reload_amount = Setting.minimum_deposit
  end

  teardown do
    Setting.minimum_deposit = @original_min_reload_amount
  end

  def test_valid_fixture_is_valid
    assert valid_type.valid?
  end

  def test_invalid_without_amount
    type = valid_type
    type.amount = nil
    assert type.invalid?
  end

  def test_invalid_when_amount_is_smaller_than_required_minimum
    type = valid_type
    Setting.minimum_deposit = 0.02

    type.amount = 0.01

    assert type.invalid?
  end

  def test_valid_when_amount_equals_allowed_minimum
    type = valid_type
    Setting.minimum_deposit = 0.02

    type.amount = 0.02

    assert type.valid?
  end

  def test_invalid_without_threshold
    type = valid_type
    type.threshold = nil
    assert type.invalid?
  end

  def test_invalid_when_threshold_is_less_than_zero
    type = valid_type
    type.threshold = -1
    assert type.invalid?
  end

  def test_serializes_to_json
    type = BalanceAutoReloadTypes::Threshold.new(amount: 100, threshold: 10)
    assert_equal ({ name: 'threshold', amount: 100, threshold: 10 }).to_json, type.to_json
  end

  private

  def valid_type
    BalanceAutoReloadTypes::Threshold.new(amount: Setting.minimum_deposit, threshold: 0)
  end
end