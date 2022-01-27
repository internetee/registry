require 'test_helper'

class PaymentStatusIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:unpaid)
    sign_in users(:api_bestnames)
  end

  def test_update_payment_status_should_create_succesfully_billing_instaces
    payload = {
      "order_reference" => @invoice.number,
      "transaction_time" => Time.zone.now - 2.minute,
      "standing_amount" => @invoice.total,
      "payment_state" => 'settled'
    }

    assert_difference -> { @invoice.payment_orders.count } do
      assert_difference -> { BankTransaction.count } do
        put eis_billing_payment_status_path,  params: payload,
          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end

    bank_transaction = BankTransaction.order(created_at: :desc).first
    invoice_payment_order = @invoice.payment_orders.order(created_at: :desc).first

    assert_equal bank_transaction.sum, @invoice.total
    assert_equal invoice_payment_order.status, "paid"
    assert_equal @invoice.account_activity.activity_type, "add_credit"

    assert_response :ok
  end

  def test_update_payment_status_should_create_failed_payment
    payload = {
      "order_reference" => @invoice.number,
      "transaction_time" => Time.zone.now - 2.minute,
      "standing_amount" => @invoice.total,
      "payment_state" => 'cancelled'
    }

    assert_difference -> { @invoice.payment_orders.count } do
      assert_difference -> { BankTransaction.count } do
        put eis_billing_payment_status_path,  params: payload,
          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end

    bank_transaction = BankTransaction.order(created_at: :desc).first
    invoice_payment_order = @invoice.payment_orders.order(created_at: :desc).first

    assert_equal bank_transaction.sum, @invoice.total
    assert_equal invoice_payment_order.status, "failed"
    assert_equal @invoice.account_activity.activity_type, "add_credit"

    assert_response :ok
  end
end
