require 'test_helper'

class PaymentCallbackTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    sign_in @user

    @payment_order = payment_orders(:everypay_issued)
    @invoice = invoices(:one)
    @invoice.update!(account_activity: nil, total: 12)
  end

  def test_every_pay_callback_returns_status_200
    request_params = every_pay_request_params
    post "/registrar/pay/callback/#{@payment_order.id}", params: request_params

    assert_response :ok
  end

  def test_invoice_is_marked_as_paid
    request_params = every_pay_request_params
    post "/registrar/pay/callback/#{@payment_order.id}", params: request_params

    assert @payment_order.invoice.paid?
  end

  def failure_log_is_created_if_unsuccessful_payment
    request_params = every_pay_request_params.dup
    request_params['payment_state'] = 'cancelled'
    request_params['transaction_result'] = 'failed'

    post "/registrar/pay/callback/#{@payment_order.id}", params: request_params

    @payment_order.reload
    assert @payment_order.cancelled?
    assert_includes @payment_order.notes, 'Payment state: cancelled'
  end

  private

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
end
