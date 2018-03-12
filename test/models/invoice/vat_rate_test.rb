require 'test_helper'

class InvoiceVATRateTest < ActiveSupport::TestCase
  def setup
    @invoice = invoices(:valid)
  end

  def test_optional_vat_rate
    @invoice.vat_rate = nil
    assert @invoice.valid?
  end

  def test_vat_rate_validation
    @invoice.vat_rate = -1
    assert @invoice.invalid?

    @invoice.vat_rate = 0
    assert @invoice.valid?

    @invoice.vat_rate = 99.9
    assert @invoice.valid?

    @invoice.vat_rate = 100
    assert @invoice.invalid?
  end

  def test_serializes_and_deserializes_vat_rate
    invoice = @invoice.dup
    invoice.invoice_items = @invoice.invoice_items
    invoice.vat_rate = BigDecimal('25.5')
    invoice.save!
    invoice.reload
    assert_equal BigDecimal('25.5'), invoice.vat_rate
  end

  def test_vat_rate_defaults_to_effective_vat_rate_of_a_registrar
    registrar = registrars(:bestnames)

    registrar.stub(:effective_vat_rate, 55) do
      invoice = Invoice.new(buyer: registrar)
      assert_equal 55, invoice.vat_rate
    end
  end

  def test_vat_rate_cannot_be_updated
    @invoice.vat_rate = 21
    @invoice.save!
    @invoice.reload
    refute_equal 21, @invoice.vat_rate
  end
end
