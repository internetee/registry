require 'test_helper'

class Invoice::VatRateCalculatorTest < ActiveSupport::TestCase
  def test_applies_registry_vat_rate_when_registrar_is_vat_liable_locally
    registry_vat_rate = 20
    registry = Registry.new(vat_rate: registry_vat_rate, vat_country: Country.new(:us))
    registrar = Registrar.new(vat_rate: 10, vat_country: Country.new(:us))

    vat_calculator = Invoice::VatRateCalculator.new(registry: registry, registrar: registrar)

    assert_equal registry_vat_rate, vat_calculator.calculate
  end

  def test_applies_registrar_vat_rate_when_registrar_is_vat_liable_in_foreign_country
    registrar_vat_rate = 20
    registry = Registry.new(vat_rate: 10, vat_country: Country.new(:gb))
    registrar = Registrar.new(vat_rate: registrar_vat_rate, vat_country: Country.new(:us))

    vat_calculator = Invoice::VatRateCalculator.new(registry: registry, registrar: registrar)

    assert_equal registrar_vat_rate, vat_calculator.calculate
  end

  def test_applies_zero_vat_rate_when_registrar_is_vat_liable_in_foreign_country_and_vat_rate_is_absent
    registry = Registry.new(vat_country: Country.new(:gb))
    registrar = Registrar.new(vat_rate: nil, vat_country: Country.new(:us))

    vat_calculator = Invoice::VatRateCalculator.new(registry: registry, registrar: registrar)

    assert vat_calculator.calculate.zero?
  end
end