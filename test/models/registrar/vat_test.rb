require 'test_helper'

class RegistrarVATTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
  end

  def test_optional_vat_no
    @registrar.vat_no = ''
    assert @registrar.valid?

    @registrar.vat_no = 'any'
    assert @registrar.valid?
  end

  def test_apply_vat_rate_from_registry_when_registrar_is_local_vat_payer
    Setting.registry_country_code = 'US'
    @registrar.address_country_code = 'US'

    Registry.instance.stub(:vat_rate, BigDecimal('5.5')) do
      assert_equal BigDecimal('5.5'), @registrar.effective_vat_rate
    end
  end

  def test_require_no_vat_rate_when_registrar_is_local_vat_payer
    @registrar.vat_rate = 1
    assert @registrar.invalid?

    @registrar.vat_rate = nil
    assert @registrar.valid?
  end

  def test_apply_vat_rate_from_registrar_when_registrar_is_foreign_vat_payer
    Setting.registry_country_code = 'US'
    @registrar.address_country_code = 'DE'
    @registrar.vat_rate = BigDecimal('5.6')
    assert_equal BigDecimal('5.6'), @registrar.effective_vat_rate
  end

  def test_require_vat_rate_when_registrar_is_foreign_vat_payer_and_vat_no_is_absent
    @registrar.address_country_code = 'DE'
    @registrar.vat_no = ''

    @registrar.vat_rate = ''
    assert @registrar.invalid?
    assert @registrar.errors.added?(:vat_rate, :blank)

    @registrar.vat_rate = 5
    assert @registrar.valid?
  end

  def test_require_no_vat_rate_when_registrar_is_foreign_vat_payer_and_vat_no_is_present
    @registrar.address_country_code = 'DE'
    @registrar.vat_no = 'valid'

    @registrar.vat_rate = 1
    assert @registrar.invalid?

    @registrar.vat_rate = nil
    assert @registrar.valid?
  end

  def test_vat_rate_validation
    @registrar.address_country_code = 'DE'
    @registrar.vat_no = ''

    @registrar.vat_rate = -1
    assert @registrar.invalid?

    @registrar.vat_rate = 0
    assert @registrar.valid?

    @registrar.vat_rate = 99.9
    assert @registrar.valid?

    @registrar.vat_rate = 100
    assert @registrar.invalid?
  end

  def test_serializes_and_deserializes_vat_rate
    @registrar.address_country_code = 'DE'
    @registrar.vat_rate = BigDecimal('25.5')
    @registrar.save!
    @registrar.reload
    assert_equal BigDecimal('25.5'), @registrar.vat_rate
  end

  def test_parses_vat_rate_as_a_string
    @registrar.vat_rate = '25.5'
    assert_equal BigDecimal('25.5'), @registrar.vat_rate
  end

  def test_treats_empty_vat_rate_as_nil
    @registrar.vat_rate = ''
    assert_nil @registrar.vat_rate
  end
end
