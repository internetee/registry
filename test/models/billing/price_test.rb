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

    price.duration = Billing::Price.durations.values.first
    assert price.valid?
  end

  def test_returns_operation_categories
    operation_categories = %w[create renew]
    assert_equal operation_categories, Billing::Price.operation_categories
  end

  def test_returns_durations
    durations = {
      '3 months' => 3.months,
      '6 months' => 6.months,
      '9 months' => 9.months,
      '1 year' => 1.year,
      '2 years'=> 2.years,
      '3 years'=> 3.years,
      '4 years'=> 4.years,
      '5 years'=> 5.years,
      '6 years'=> 6.years,
      '7 years'=> 7.years,
      '8 years'=> 8.years,
      '9 years'=> 9.years,
      '10 years'=> 10.years,
    }
    assert_equal durations, Billing::Price.durations
  end

  def test_returns_statuses
    statuses = %w[upcoming effective expired]
    assert_equal statuses, Billing::Price.statuses
  end

  def test_price_for_selects_tariff_at_requested_past_or_future_date
    travel_to Time.zone.parse('2027-06-01 12:00')
    past = billing_prices(:renew_one_year)
    past.update!(valid_from: Time.zone.parse('2026-01-01'),
                 valid_to: Time.zone.parse('2026-12-31'))
    current = past.dup
    current.update!(price_cents: 1200, valid_from: Time.zone.parse('2027-01-01'),
                    valid_to: Time.zone.parse('2027-12-31'))
    future = current.dup
    future.update!(price_cents: 1500, valid_from: Time.zone.parse('2028-01-01'), valid_to: nil)

    assert_equal past, Billing::Price.price_for(past.zone, 'renew', 1.year,
                                               at: Time.zone.parse('2026-06-01'))
    assert_equal future, Billing::Price.price_for(past.zone, 'renew', 1.year,
                                                 at: Time.zone.parse('2028-06-01'))
    assert_equal current, Billing::Price.price_for(past.zone, 'renew', 1.year)
  end

  def test_valid_uses_the_requested_day_boundaries
    travel_to Time.zone.parse('2027-06-01 12:00')
    at = Time.zone.parse('2026-07-05 12:00')
    price = billing_prices(:renew_one_year)
    price.update!(valid_from: at.beginning_of_day, valid_to: at.beginning_of_day)

    assert_includes Billing::Price.valid(at), price
    assert_equal price, Billing::Price.price_for(price.zone, 'renew', 1.year, at: at)
    refute_includes Billing::Price.valid(at.advance(days: 1)), price

    price.update!(valid_from: at.end_of_day, valid_to: nil)
    assert_equal price, Billing::Price.price_for(price.zone, 'renew', 1.year, at: at)
    refute_includes Billing::Price.valid(at.advance(days: -1)), price
  end

  private

  def valid_price
    billing_prices(:create_one_month)
  end
end
