require 'test_helper'

class SendEInvoiceJobTest < ActiveJob::TestCase

  def teardown
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear
  end

  def test_if_invoice_is_sent
    @invoice = invoices(:one)
    @invoice.account_activity.destroy
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear

    assert_nothing_raised do
      perform_enqueued_jobs do
        SendEInvoiceJob.perform_now(@invoice.id, true)
      end
    end
    @invoice.reload

    assert_not @invoice.e_invoice_sent_at.blank?
    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end
end
