require 'test_helper'

class CancelOverdueInvoicesTaskTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
    eliminate_effect_of_other_invoices
  end

  def test_cancels_overdue_invoices
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-05')
    assert @invoice.cancellable?

    capture_io do
      run_task
    end
    @invoice.reload

    assert @invoice.cancelled?
  end

  def test_output
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-05')
    assert @invoice.cancellable?

    assert_output "Invoice ##{@invoice.id} is cancelled\nCancelled total: 1\n" do
      run_task
    end
  end

  private

  def eliminate_effect_of_other_invoices
    Invoice.connection.disable_referential_integrity do
      Invoice.where("id != #{@invoice.id}").delete_all
    end
  end

  def run_task
    Rake::Task['invoices:cancel_overdue'].execute
  end
end