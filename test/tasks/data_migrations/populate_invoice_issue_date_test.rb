require 'test_helper'

class PopulateInvoiceIssueDateTaskTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_populates_invoice_issue_date
    eliminate_effect_of_other_invoices
    @invoice.update_columns(issue_date: nil, created_at: Time.zone.parse('2010-07-05'))
    assert_nil @invoice.read_attribute(:issue_date)

    capture_io { run_task }
    @invoice.reload

    assert_equal Date.parse('2010-07-05'), @invoice.issue_date
  end

  def test_outputs_results
    eliminate_effect_of_other_invoices
    @invoice.update_columns(issue_date: nil, created_at: Time.zone.parse('2010-07-05'))

    assert_output("Invoices processed: 1\n") { run_task }
  end

  private

  def eliminate_effect_of_other_invoices
    Invoice.connection.disable_referential_integrity do
      Invoice.delete_all("id != #{@invoice.id}")
    end
  end

  def run_task
    Rake::Task['data_migrations:populate_invoice_issue_date'].execute
  end
end
