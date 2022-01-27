require 'test_helper'

class PaymentStatusIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:unpaid)
    sign_in users(:api_bestnames)
  end

  def test_update_payment_status
    payload = {
      "order_reference" => @invoice.number,
      "paid_at" => Time.zone.now - 2.minute,
      "sum" => @invoice.total,
      "payment_state" => 'settled'
    }

    p @invoice.payment_orders.count
    p BankTransaction.count

    assert_difference -> { @invoice.payment_orders.count } do
      assert_difference -> { BankTransaction.count } do
        put eis_billing_payment_status_path,  params: payload,
          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end

    assert_equal @invoice.account_activity.activity_type, "add_credit"

    assert_response :ok
  end
end
