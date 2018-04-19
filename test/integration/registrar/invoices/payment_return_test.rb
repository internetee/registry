require 'test_helper'

class PaymentReturnTest < ActionDispatch::IntegrationTest
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
      amount:              "12.0",
      order_reference:     "e468a2d59a731ccc546f2165c3b1a6",
      account_id:          "EUR3D1",
      cc_type:             "master_card",
      cc_last_four_digits: "0487",
      cc_month:            "10",
      cc_year:             "2018",
      cc_holder_name:      "John Doe",
      hmac_fields:         "account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result",
      hmac:                "72fc94f117389cf5d34dba18a18d20886edb2bbb",
      invoice_id:          "12900000",
    }
  end

  def bank_link_request_params
    {
      "VK_SERVICE":   "1111",
      "VK_VERSION":   "008",
      "VK_SND_ID":     "KIAupMEE's",
      "VK_AMOUNT":     "12.00",
      "VK_REC_ID":     "1235",
      "VK_CURR":       "EUR",
      "VK_T_NO":       "1234",
      "VK_STAMP":      "ahdfjkadsfhjk",
      "VK_REC_ACC":    "1234",
      "VK_REC_NAME":   "John Doe",
      "VK_SND_ACC":    "1234",
      "VK_SND_NAME":  "Doe John",
      "VK_REF":        "1234",
      "VK_MSG":        "Foo",
      "VK_T_DATETIME": "2018-04-19T15:52:59+0300",
      invoice_id:     "12900000",
    }
  end

  def test_every_pay_return_creates_activity_redirects_to_invoice_path
    create_invoice_with_items
    request_params = every_pay_request_params.merge(invoice_id: @invoice.id)

    account_activity_count = AccountActivity.count
    post "/registrar/pay/return/every_pay", request_params
    assert_equal(302, response.status)
    assert_redirected_to(registrar_invoice_path(@invoice))
    assert_equal(account_activity_count + 1, AccountActivity.count)
  end

  def test_Every_Pay_return_raises_RecordNotFound
    create_invoice_with_items
    request_params = every_pay_request_params.merge(invoice_id: "178907")
    assert_raises(ActiveRecord::RecordNotFound) do
      post "/registrar/pay/return/every_pay", request_params
    end
  end

  def test_bank_link_return_redirects_to_invoice_paths
    skip("Need credentials to model the expected request")
    create_invoice_with_items
    request_params = every_pay_request_params.merge(invoice_id: @invoice.id)
    account_activity_count = AccountActivity.count

    post "/registrar/pay/return/seb", request_params
    assert_equal(302, response.status)
    assert_redirected_to(registrar_invoice_path(@invoice))
    assert_equal(account_activity_count + 1, AccountActivity.count)
  end

  def test_bank_link_return
    create_invoice_with_items
    request_params = bank_link_request_params.merge(invoice_id: "178907")
    assert_raises(ActiveRecord::RecordNotFound) do
      post "/registrar/pay/return/seb", request_params
    end
  end
end
