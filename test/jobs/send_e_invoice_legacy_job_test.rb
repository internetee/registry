require 'test_helper'

class SendEInvoiceLegacyJobTest < ActiveJob::TestCase

  def teardown
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear

    msg = { message: 'success' }
    stub_request(:post, "https://eis_billing_system:3000/api/v1/e_invoice/e_invoice")
      .to_return(status: 200, body: msg.to_json, headers: {})
  end

  def test_if_invoice_is_sent
    @invoice = invoices(:one)
    @invoice.account_activity.destroy
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear

    assert_nothing_raised do
      perform_enqueued_jobs do
        SendEInvoiceLegacyJob.perform_now(@invoice.id, payable: true)
      end
    end
    @invoice.reload

    assert_not @invoice.e_invoice_sent_at.blank?
    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end
end
