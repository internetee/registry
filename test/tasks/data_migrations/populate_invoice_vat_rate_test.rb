require 'test_helper'

class PopulateInvoiceVatRateTaskTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_populates_invoice_issue_date
    eliminate_effect_of_all_invoices_except(@invoice)
    @invoice.update_columns(vat_rate: nil)

    capture_io do
      run_task
    end
    @invoice.reload

    assert_not_nil @invoice.vat_rate
  end

  def test_output
    eliminate_effect_of_all_invoices_except(@invoice)
    @invoice.update_columns(vat_rate: nil)

    assert_output "Invoices processed: 1\n" do
      run_task
    end
  end

  private

  def eliminate_effect_of_all_invoices_except(invoice)
    Invoice.connection.disable_referential_integrity do
      Invoice.delete_all("id != #{invoice.id}")
    end
  end

  def run_task
    Rake::Task['data_migrations:populate_invoice_vat_rate'].execute
  end
end