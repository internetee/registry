require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
  end

  def test_valid
    assert @registrar.valid?, proc { @registrar.errors.full_messages }
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

  def test_validates_reference_number_format
    @registrar.reference_no = '1'
    assert @registrar.invalid?

    @registrar.reference_no = '11'
    assert @registrar.valid?

    @registrar.reference_no = '1' * 20
    assert @registrar.valid?

    @registrar.reference_no = '1' * 21
    assert @registrar.invalid?

    @registrar.reference_no = '1a'
    assert @registrar.invalid?
  end

  def test_disallows_non_unique_reference_numbers
    registrars(:bestnames).update!(reference_no: '1234')

    assert_raises ActiveRecord::RecordNotUnique do
      registrars(:goodnames).update!(reference_no: '1234')
    end
  end
end
