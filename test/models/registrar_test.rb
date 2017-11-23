require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:bestnames)
  end

  def test_valid
    assert @registrar.valid?
  end

  def test_rejects_absent_accounting_customer_code
    @registrar.accounting_customer_code = nil
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_requires_country_code
    @registrar.country_code = nil
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_requires_language
    @registrar.language = nil
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_has_default_language
    Setting.default_language = 'en'
    registrar = Registrar.new
    assert_equal 'en', registrar.language
  end

  def test_overrides_default_language
    Setting.default_language = 'en'
    registrar = Registrar.new(language: 'de')
    assert_equal 'de', registrar.language
  end

  def test_rejects_vat_number_when_local_vat_payer
    Registry.instance.stub(:legal_address_country, Country.new('US')) do
      @registrar.vat_no = 'US1'
      @registrar.validate
      assert @registrar.invalid?
    end
  end

  def test_rejects_vat_rate_when_local_vat_payer
    Registry.instance.stub(:legal_address_country, Country.new('US')) do
      @registrar.vat_rate = 20
      @registrar.validate
      assert @registrar.invalid?
    end
  end

  def test_rejects_negative_vat_rate
    @registrar.vat_rate = -1
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_rejects_vat_rate_greater_than_max
    @registrar.vat_rate = 100
    @registrar.validate
    assert @registrar.invalid?
  end

  def test_converts_integer_vat_rate_to_fractional
    @registrar = registrars(:foreign_vat_payer_with_rate)
    assert_equal 20, @registrar.vat_rate
  end

  def test_requires_vat_rate_when_foreign_vat_payer_without_number
    Registry.instance.stub(:legal_address_country, Country.new('GB')) do
      @registrar.vat_no = nil
      @registrar.validate
      assert @registrar.invalid?
    end
  end

  def test_rejects_vat_rate_when_foreign_vat_payer_with_number
    Registry.instance.stub(:legal_address_country, Country.new('GB')) do
      @registrar.vat_no = 'US1'
      @registrar.vat_rate = 1
      @registrar.validate
      assert @registrar.invalid?
    end
  end
end
