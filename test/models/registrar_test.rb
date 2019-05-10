require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
  end

  def test_valid_registrar_is_valid
    assert valid_registrar.valid?, proc { valid_registrar.errors.full_messages }
  end

  def test_invalid_fixture_is_invalid
    assert registrars(:invalid).invalid?
  end

  def test_invalid_without_name
    registrar = valid_registrar
    registrar.name = ''
    assert registrar.invalid?
  end

  def test_invalid_without_reg_no
    registrar = valid_registrar
    registrar.reg_no = ''
    assert registrar.invalid?
  end

  def test_invalid_without_email
    registrar = valid_registrar
    registrar.email = ''
    assert registrar.invalid?
  end

  def test_invalid_without_accounting_customer_code
    registrar = valid_registrar
    registrar.accounting_customer_code = ''
    assert registrar.invalid?
  end

  def test_invalid_without_language
    registrar = valid_registrar
    registrar.language = ''
    assert registrar.invalid?
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
    registrar = Registrar.new(address_street: 'Main Street 1', address_zip: '1234',
                              address_city: 'NY', address_state: 'NY State')
    assert_equal 'Main Street 1, NY, NY State, 1234', registrar.address
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

  def test_issues_new_invoice
    travel_to Time.zone.parse('2010-07-05')
    @original_days_to_keep_invoices_active_setting = Setting.days_to_keep_invoices_active
    Setting.days_to_keep_invoices_active = 10

    invoice = @registrar.issue_prepayment_invoice(100)

    assert_equal Date.parse('2010-07-05'), invoice.issue_date
    assert_equal Date.parse('2010-07-15'), invoice.due_date

    Setting.days_to_keep_invoices_active = @original_days_to_keep_invoices_active_setting
  end

  private

  def valid_registrar
    registrars(:bestnames)
  end
end
