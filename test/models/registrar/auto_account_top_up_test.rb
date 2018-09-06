require 'test_helper'

class RegistrarAutoAccountTopUpTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
  end

  def test_deactivated_by_default
    registrar = Registrar.new
    assert_not registrar.auto_account_top_up_activated
  end

  def test_valid_without_low_balance_threshold_when_deactivated
    @registrar.auto_account_top_up_activated = false
    @registrar.auto_account_top_up_low_balance_threshold = nil
    assert @registrar.valid?
  end

  def test_invalid_without_low_balance_threshold_when_activated
    @registrar.auto_account_top_up_activated = true
    @registrar.auto_account_top_up_low_balance_threshold = nil
    assert @registrar.invalid?
  end

  def test_low_balance_threshold_validation
    @registrar.auto_account_top_up_low_balance_threshold = -1
    assert @registrar.invalid?

    @registrar.auto_account_top_up_low_balance_threshold = 0
    assert @registrar.valid?

    @registrar.auto_account_top_up_low_balance_threshold = 0.01
    assert @registrar.valid?
  end

  def test_valid_without_top_up_amount_when_deactivated
    @registrar.auto_account_top_up_activated = false
    @registrar.auto_account_top_up_amount = nil
    assert @registrar.valid?
  end

  def test_invalid_without_top_up_amount_when_activated
    @registrar.auto_account_top_up_activated = true
    @registrar.auto_account_top_up_amount = nil
    assert @registrar.invalid?
  end

  def test_invalid_when_top_up_amount_is_less_than_minimum_deposit_setting
    @original_minimum_deposit_setting = Setting.minimum_deposit

    Setting.minimum_deposit = 5
    @registrar.auto_account_top_up_amount = 4

    assert @registrar.invalid?

    Setting.minimum_deposit = @original_minimum_deposit_setting
  end

  def test_valid_without_iban_when_deactivated
    @registrar.auto_account_top_up_activated = false
    @registrar.auto_account_top_up_iban = nil
    assert @registrar.valid?
  end

  def test_invalid_without_iban_when_activated
    @registrar.auto_account_top_up_activated = true
    @registrar.auto_account_top_up_iban = nil
    assert @registrar.invalid?
  end

  def test_normalizes_iban_when_persisted
    @registrar.update!(auto_account_top_up_iban: '  de91 1000 0000 0123 4567 89  ')
    @registrar.reload
    assert_equal 'DE91100000000123456789', @registrar.auto_account_top_up_iban
  end
end
