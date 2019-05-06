require 'test_helper'

class RegistryTest < ActiveSupport::TestCase
  setup do
    @registry = Registry.send(:new)
  end

  def test_implements_singleton
    assert_equal Registry.instance.object_id, Registry.instance.object_id
  end

  def test_vat_rate
    original_vat_prc = Setting.registry_vat_prc
    Setting.registry_vat_prc = 0.25

    assert_equal BigDecimal(25), @registry.vat_rate

    Setting.registry_vat_prc = original_vat_prc
  end

  def test_returns_billing_address
    Setting.registry_street = 'Main Street'
    Setting.registry_zip = '1234'
    Setting.registry_city = 'NY'
    Setting.registry_state = 'NY State'
    Setting.registry_country_code = 'US'

    assert_equal Address.new(street: 'Main Street',
                             zip: '1234',
                             city: 'NY',
                             state: 'NY State',
                             country: Country.new('US')), @registry.billing_address
  end
end