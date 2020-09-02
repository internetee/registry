require 'test_helper'

class Billing::PriceTest < ActiveSupport::TestCase
  setup do
    @user = users(:api_bestnames)
  end

  def test_valid_price_fixture_is_valid
    assert valid_price.valid?, proc { valid_price.errors.full_messages }
  end

  def test_invalid_without_price
    price = valid_price
    price.price = ''
    assert price.invalid?
  end

  def test_validates_price_format
    price = valid_price

    price.price = -1
    assert price.invalid?

    price.price = 0
    assert price.valid?, proc { price.errors.full_messages }

    price.price = "1#{I18n.t('number.currency.format.separator')}1"
    assert price.valid?

    price.price = 1
    assert price.valid?
  end

  def test_invalid_without_effective_date
    price = valid_price
    price.valid_from = ''
    assert price.invalid?
  end

  def test_invalid_without_operation_category
    price = valid_price
    price.operation_category = ''
    assert price.invalid?
  end

  def test_validates_operation_category_format
    price = valid_price

    price.operation_category = 'invalid'
    assert price.invalid?

    price.operation_category = Billing::Price.operation_categories.first
    assert price.valid?
  end

  def test_invalid_without_duration
    price = valid_price
    price.duration = ''
    assert price.invalid?
  end

  def test_validates_duration_format
    price = valid_price

    price.duration = 'invalid'
    assert price.invalid?

    price.duration = Billing::Price.durations.first
    assert price.valid?
  end

  def test_returns_operation_categories
    operation_categories = %w[create renew]
    assert_equal operation_categories, Billing::Price.operation_categories
  end

  def test_returns_durations
    durations = [
      '3 mons',
      '6 mons',
      '9 mons',
      '1 year',
      '2 years',
      '3 years',
      '4 years',
      '5 years',
      '6 years',
      '7 years',
      '8 years',
      '9 years',
      '10 years',
    ]
    assert_equal durations, Billing::Price.durations
  end

  def test_returns_statuses
    statuses = %w[upcoming effective expired]
    assert_equal statuses, Billing::Price.statuses
  end

  private

  def valid_price
    billing_prices(:create_one_month)
  end
end
