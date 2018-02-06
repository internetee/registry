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
end
