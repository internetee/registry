require 'test_helper'

class RegistryTest < ActiveSupport::TestCase
  setup do
    @registry = Registry.send(:new)
  end

  def test_implements_singleton
    assert_equal Registry.instance.object_id, Registry.instance.object_id
  end

  def test_vat_rate
    Setting.registry_vat_prc = 0.25
    assert_equal BigDecimal(25), @registry.vat_rate
  end
end
