require 'test_helper'

class RegistryTest < ActiveSupport::TestCase
  setup do
    @original_registry_vat_rate = Setting.registry_vat_prc
    @original_registry_country_code = Setting.registry_country_code
  end

  teardown do
    Setting.registry_vat_prc = @original_registry_vat_rate
    Setting.registry_country_code = @original_registry_country_code
  end

  def test_returns_current_registry
    Setting.registry_vat_prc = 0.2
    Setting.registry_country_code = 'US'

    registry = Registry.current
    assert_equal 20, registry.vat_rate
    assert_equal Country.new(:us), registry.vat_country
  end
end