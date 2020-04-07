require 'test_helper'

class RegistrarTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
    @original_default_language = Setting.default_language
    @original_days_to_keep_invoices_active = Setting.days_to_keep_invoices_active
  end

  teardown do
    Setting.default_language = @original_default_language
    Setting.days_to_keep_invoices_active = @original_days_to_keep_invoices_active
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

  def test_email_format_validation
    registrar = valid_registrar

    registrar.email = 'invalid'
    assert registrar.invalid?

    registrar.email = 'valid@email.test'
    assert registrar.valid?
  end

  def test_invalid_without_accounting_customer_code
    registrar = valid_registrar
    registrar.accounting_customer_code = ''
    assert registrar.invalid?
  end

  def test_optional_billing_email
    registrar = valid_registrar
    registrar.billing_email = ''
    assert registrar.valid?
  end

  def test_billing_email_format_validation
    registrar = valid_registrar

    registrar.billing_email = 'invalid'
    assert registrar.invalid?

    registrar.billing_email = 'valid@email.test'
    assert registrar.valid?
  end

  def test_returns_billing_email_when_provided
    billing_email = 'billing@registrar.test'
    registrar = Registrar.new(billing_email: billing_email)
    assert_equal billing_email, registrar.billing_email
  end

  def test_billing_email_fallback
    contact_email = 'info@registrar.test'
    registrar = Registrar.new(contact_email: contact_email, billing_email: '')
    assert_equal contact_email, registrar.billing_email
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
    Setting.days_to_keep_invoices_active = 10

    invoice = @registrar.issue_prepayment_invoice(100)

    assert_equal Date.parse('2010-07-05'), invoice.issue_date
    assert_equal Date.parse('2010-07-15'), invoice.due_date
  end

  def test_issues_e_invoice_along_with_invoice
    EInvoice::Providers::TestProvider.deliveries.clear

    @registrar.issue_prepayment_invoice(100)

    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_invalid_without_address_street
    registrar = valid_registrar
    registrar.address_street = ''
    assert registrar.invalid?
  end

  def test_invalid_without_address_city
    registrar = valid_registrar
    registrar.address_city = ''
    assert registrar.invalid?
  end

  def test_invalid_without_address_country_code
    registrar = valid_registrar
    registrar.address_country_code = ''
    assert registrar.invalid?
  end

  def test_aliases_contact_email_to_email
    email = 'info@registrar.test'
    registrar = Registrar.new(email: email)
    assert_equal email, registrar.contact_email
  end

  def test_full_address
    registrar = Registrar.new(address_street: 'Main Street 1', address_zip: '1234',
                              address_city: 'NY', address_state: 'NY State')
    assert_equal 'Main Street 1, NY, NY State, 1234', registrar.address
  end

  def test_invalid_with_vat_rate_when_registrar_is_vat_liable_locally
    registrar = registrar_with_local_vat_liability

    registrar.vat_rate = 1

    assert registrar.invalid?
    assert_includes registrar.errors.full_messages_for(:vat_rate),
                    'VAT rate must be blank when a registrar is VAT-registered in the same' \
                    ' country as registry'
  end

  def test_invalid_with_vat_rate_when_registrar_is_vat_liable_in_foreign_country_and_vat_no_is_present
    registrar = registrar_with_foreign_vat_liability

    registrar.vat_no = 'valid'
    registrar.vat_rate = 1

    assert registrar.invalid?
  end

  def test_invalid_without_vat_rate_when_registrar_is_vat_liable_in_foreign_country_and_vat_no_is_absent
    registrar = registrar_with_foreign_vat_liability

    registrar.vat_no = ''
    registrar.vat_rate = ''

    assert registrar.invalid?
  end

  def test_vat_rate_validation
    registrar = registrar_with_foreign_vat_liability

    registrar.vat_rate = -1
    assert registrar.invalid?

    registrar.vat_rate = 0
    assert registrar.valid?

    registrar.vat_rate = 99.9
    assert registrar.valid?

    registrar.vat_rate = 100
    assert registrar.invalid?
  end

  def test_serializes_and_deserializes_vat_rate
    @registrar.address_country_code = 'DE'
    @registrar.vat_rate = BigDecimal('25.5')
    @registrar.save!
    @registrar.reload
    assert_equal BigDecimal('25.5'), @registrar.vat_rate
  end

  def test_aliases_vat_country_to_country
    vat_country = Country.new(:us)
    registrar = Registrar.new(vat_country: vat_country)
    assert_equal vat_country, registrar.vat_country
  end

  def test_returns_iban_for_e_invoice_delivery_channel
    iban = 'GB33BUKB20201555555555'
    registrar = Registrar.new(iban: iban)
    assert_equal iban, registrar.e_invoice_iban
  end

  def test_stores_history
    @registrar.address_country_code = 'DE'
    @registrar.vat_rate = BigDecimal('25.5')

    assert_difference '@registrar.versions.count', 1 do
      @registrar.save!
    end
  end

  private

  def valid_registrar
    registrars(:bestnames)
  end

  def registrar_with_local_vat_liability
    registrar = valid_registrar
    registrar.vat_country = Country.new(:us)
    Registry.current.vat_country = Country.new(:us)
    registrar
  end

  def registrar_with_foreign_vat_liability
    registrar = valid_registrar
    registrar.vat_country = Country.new(:gb)
    Registry.current.vat_country = Country.new(:us)
    registrar
  end
end
