require "test_helper"

class DirectoInvoiceForwardJobTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_xml_is_include_transaction_date
    @invoice.update(total: @invoice.account_activity.bank_transaction.sum)
    @invoice.account_activity.bank_transaction.update(paid_at: Time.zone.now)

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      request.body.include? 'TransactionDate'
    end

    assert_nothing_raised do
      DirectoInvoiceForwardJob.run(monthly: false)
    end
  end
end
