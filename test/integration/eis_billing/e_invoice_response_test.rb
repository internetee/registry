require 'test_helper'

class EInvoiceResponseTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_invoice_should_be_mark_as_sent
    assert_nil @invoice.e_invoice_sent_at
    put eis_billing_e_invoice_response_path, params: { invoice_number: @invoice.number}

    @invoice.reload
    assert_not_nil @invoice.e_invoice_sent_at
  end

  def test_responds_with_json_not_found_for_unknown_invoice
    put eis_billing_e_invoice_response_path, params: { invoice_number: '999999999' }

    assert_response :not_found
    assert_equal 'Invoice not found', JSON.parse(response.body)['message']
  end
end
