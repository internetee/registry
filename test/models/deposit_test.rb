require 'test_helper'

class DepositTest < ActiveSupport::TestCase
  def setup
    super

    @deposit = Deposit.new(registrar: registrars(:bestnames))
    @minimum_deposit = Setting.minimum_deposit
    Setting.minimum_deposit = 1.00
  end

  def teardown
    super

    Setting.minimum_deposit = @minimum_deposit
  end

  def test_validate_amount_cannot_be_lower_than_0_01
    Setting.minimum_deposit = 0.0
    @deposit.amount = -10
    refute(@deposit.valid?)
    assert(@deposit.errors.full_messages.include?("Amount is too small. Minimum deposit is 0.01 EUR"))
  end

  def test_validate_amount_cannot_be_lower_than_minimum_deposit
    @deposit.amount = 0.10
    refute(@deposit.valid?)

    assert(@deposit.errors.full_messages.include?("Amount is too small. Minimum deposit is 1.0 EUR"))
  end

  def test_registrar_must_be_set
    deposit = Deposit.new(amount: 120)
    refute(deposit.valid?)

    assert(deposit.errors.full_messages.include?("Registrar is missing"))
  end

  def test_amount_is_converted_from_string
    @deposit.amount = "12.00"
    assert_equal(BigDecimal.new("12.00"), @deposit.amount)

    @deposit.amount = "12,11"
    assert_equal(BigDecimal.new("12.11"), @deposit.amount)
  end

  def test_amount_is_converted_from_float
    @deposit.amount = 12.0044
    assert_equal(BigDecimal.new("12.0044"), @deposit.amount)

    @deposit.amount = 12.0144
    assert_equal(BigDecimal.new("12.0144"), @deposit.amount)
  end

  def test_amount_is_converted_from_nil
    @deposit.amount = nil
    assert_equal(BigDecimal.new("0.00"), @deposit.amount)
  end
end
