require 'test_helper'

class PaymentReturnTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    sign_in @user

    @invoice = invoices(:one)
    @invoice.update!(account_activity: nil, total: 12)
    @everypay_order = payment_orders(:everypay_issued)
    @banklink_order = payment_orders(:banklink_issued)
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

  def bank_link_request_params
    {
      "VK_SERVICE":    "1111",
      "VK_VERSION":    "008",
      "VK_SND_ID":     "testvpos",
      "VK_REC_ID":     "seb",
      "VK_STAMP":      1,
      "VK_T_NO":       "1",
      "VK_AMOUNT":     "12.00",
      "VK_CURR":       "EUR",
      "VK_REC_ACC":    "1234",
      "VK_REC_NAME":   "Eesti Internet",
      "VK_SND_ACC":    "1234",
      "VK_SND_NAME":   "John Doe",
      "VK_REF":        "",
      "VK_MSG":        "Order nr 1",
      "VK_T_DATETIME": "2018-04-01T00:30:00+0300",
      "VK_MAC":        "CZZvcptkxfuOxRR88JmT4N+Lw6Hs4xiQfhBWzVYldAcRTQbcB/lPf9MbJzBE4e1/HuslQgkdCFt5g1xW2lJwrVDBQTtP6DAHfvxU3kkw7dbk0IcwhI4whUl68/QCwlXEQTAVDv1AFnGVxXZ40vbm/aLKafBYgrirB5SUe8+g9FE=",
      "VK_ENCODING":   "UTF-8",
      "VK_LANG":       "ENG",
      payment_method:  "seb"
    }
  end

  def test_successful_bank_payment_marks_invoice_as_paid
    @invoice.update!(account_activity: nil)
    request_params = bank_link_request_params

    post "/registrar/pay/return/#{@banklink_order.id}", params: request_params

    @banklink_order.reload
    assert @banklink_order.invoice.paid?
  end

  def test_every_pay_return_creates_activity_redirects_to_invoice_path
    request_params = every_pay_request_params

    post "/registrar/pay/return/#{@everypay_order.id}", params: request_params
    assert_equal(302, response.status)
    assert_redirected_to(registrar_invoice_path(@invoice))
  end

  def test_every_pay_return_raises_record_not_found
    request_params = every_pay_request_params
    assert_raises(ActiveRecord::RecordNotFound) do
      post '/registrar/pay/return/123456', params: request_params
    end
  end

  def test_bank_link_return_redirects_to_invoice_paths
    request_params = bank_link_request_params

    post "/registrar/pay/return/#{@banklink_order.id}", params: request_params
    assert_equal(302, response.status)
    assert_redirected_to(registrar_invoice_path(@invoice))
  end

  def test_bank_link_return
    request_params = bank_link_request_params
    assert_raises(ActiveRecord::RecordNotFound) do
      post '/registrar/pay/return/123456', params: request_params
    end
  end

  def test_marks_as_paid_and_adds_notes_if_failed_to_bind
    request_params = bank_link_request_params

    post "/registrar/pay/return/#{@banklink_order.id}", params: request_params
    post "/registrar/pay/return/#{@banklink_order.id}", params: request_params
    @banklink_order.reload

    assert @banklink_order.notes.present?
    assert @banklink_order.paid?
    assert_includes @banklink_order.notes, 'Failed to bind'
  end

  def test_failed_bank_link_payment_creates_brief_error_explanation
    request_params = bank_link_request_params.dup
    request_params['VK_SERVICE'] = '1911'

    post "/registrar/pay/return/#{@banklink_order.id}", params: request_params

    @banklink_order.reload

    assert_includes @banklink_order.notes, 'Bank responded with code 1911'
  end

  def test_failed_every_pay_payment_creates_brief_error_explanation
    request_params = every_pay_request_params.dup
    request_params['payment_state'] = 'cancelled'
    request_params['transaction_result'] = 'failed'

    post "/registrar/pay/return/#{@everypay_order.id}", params: request_params

    @everypay_order.reload

    assert_includes @everypay_order.notes, 'Payment state: cancelled'
  end
end
