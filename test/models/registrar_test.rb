require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:bestnames)
  end

  def test_valid
    assert @registrar.valid?
  end

  def test_invalid_without_name
    @registrar.name = ''
    assert @registrar.invalid?
  end

  def test_invalid_without_reg_no
    @registrar.reg_no = ''
    assert @registrar.invalid?
  end

  def test_invalid_without_email
    @registrar.email = ''
    assert @registrar.invalid?
  end

  def test_invalid_without_accounting_customer_code
    @registrar.accounting_customer_code = ''
    assert @registrar.invalid?
  end

  def test_invalid_without_country_code
    @registrar.country_code = ''
    assert @registrar.invalid?
  end

  def test_invalid_without_language
    @registrar.language = ''
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

  def test_full_address
    assert_equal 'Main Street, New York, New York, 12345', @registrar.address
  end

  def test_reference_number_generation
    @registrar.validate
    refute_empty @registrar.reference_no
  end
end
