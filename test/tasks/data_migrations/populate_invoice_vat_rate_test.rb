require 'test_helper'

class PopulateInvoiceVatRateTaskTest < ActiveSupport::TestCase
  def test_populates_invoice_issue_date
    invoice = invoice_without_vat_rate

    capture_io do
      run_task
    end
    invoice.reload

    assert_not_nil invoice.vat_rate
  end

  def test_output
    eliminate_effect_of_all_invoices_except(invoice_without_vat_rate)

    assert_output "Invoices processed: 1\n" do
      run_task
    end
  end

  private

  def invoice_without_vat_rate
    invoice = invoices(:one)
    invoice.update_columns(vat_rate: nil)
    invoice
  end

  def eliminate_effect_of_all_invoices_except(invoice)
    Invoice.connection.disable_referential_integrity do
      Invoice.delete_all("id != #{invoice.id}")
    end
  end

  def run_task
    Rake::Task['data_migrations:populate_invoice_vat_rate'].execute
  end
end