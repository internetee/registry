require 'test_helper'

class DirectoTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_xml_is_include_transaction_date
    @invoice.update(total: @invoice.account_activity.bank_transaction.sum)
    @invoice.account_activity.bank_transaction.update(paid_at: Time.zone.now)

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="1" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      request.body.include? 'TransactionDate'
    end.to_return(status: 200, body: response)

    assert_nothing_raised do
      Directo.send_receipts
    end

    assert_not_empty @invoice.directo_records.first.request
  end
end
