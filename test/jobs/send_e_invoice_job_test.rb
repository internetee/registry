require 'test_helper'

class SendEInvoiceJobTest < ActiveSupport::TestCase

  def teardown
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear
  end

  def test_if_invoice_is_sended
    @invoice = invoices(:one)
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear

    assert_nothing_raised do
      SendEInvoiceJob.enqueue(@invoice)
    end

    assert_not @invoice.e_invoice_sent_at.blank?
    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_if_invoice_sending_retries
    @invoice = invoices(:one)
    provider_config = { password: nil,
                        test_mode: true }
    EInvoice.provider = EInvoice::Providers::OmnivaProvider.new(provider_config)
    stub_request(:get, "https://testfinance.post.ee/finance/erp/erpServices.wsdl").to_timeout

    assert_raise HTTPClient::TimeoutError do
      SendEInvoiceJob.enqueue(@invoice)
    end
    assert @invoicee_invoice_sent_at.blank?

    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear

    assert_nothing_raised do
      SendEInvoiceJob.enqueue(@invoice)
    end

    assert_not @invoice.e_invoice_sent_at.blank?
    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end
end
