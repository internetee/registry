require 'test_helper'

class PaymentCallbackTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:api_bestnames)
    login_as @user
  end

  def create_invoice_with_items
    @invoice = invoices(:for_payments_test)
    invoice_item = invoice_items(:one)

    @invoice.invoice_items << invoice_item
    @invoice.invoice_items << invoice_item
    @user.registrar.invoices << @invoice
  end

  def every_pay_request_params
    {
      nonce:               "392f2d7748bc8cb0d14f263ebb7b8932",
      timestamp:           "1524136727",
      api_username:        "ca8d6336dd750ddb",
      transaction_result:  "completed",
      payment_reference:   "fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56",
      payment_state:       "settled",
      amount:              "12.00",
      order_reference:     "e468a2d59a731ccc546f2165c3b1a6",
      account_id:          "EUR3D1",
      cc_type:             "master_card",
      cc_last_four_digits: "0487",
      cc_month:            "10",
      cc_year:             "2018",
      cc_holder_name:      "John Doe",
      hmac_fields:         "account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result",
      hmac:                "efac1c732835668cd86023a7abc140506c692f0d",
      invoice_id:          "12900000",
      payment_method:      "every_pay"
    }
  end

  def test_every_pay_callback_returns_status_200
    create_invoice_with_items
    request_params = every_pay_request_params.merge(invoice_id: @invoice.id)
    post "/registrar/pay/callback/every_pay", request_params
    assert_equal(200, response.status)
  end
end
