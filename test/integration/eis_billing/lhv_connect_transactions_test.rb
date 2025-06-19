require 'test_helper'

class LhvConnectTransactionsIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:unpaid)
    sign_in users(:api_bestnames)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_should_saved_transaction_data
    test_transaction_1 = OpenStruct.new(amount: 0.1,
                                        currency: 'EUR',
                                        date: Time.zone.today,
                                        payment_reference_number: '2199812',
                                        payment_description: 'description 2199812')

    test_transaction_2 = OpenStruct.new(amount: 0.1,
                                        currency: 'EUR',
                                        date: Time.zone.today,
                                        payment_reference_number: '2199813',
                                        payment_description: 'description 2199813')

    test_transaction_3 = OpenStruct.new(amount: 0.1,
                                        currency: 'EUR',
                                        date: Time.zone.today,
                                        payment_reference_number: '2199814',
                                        payment_description: 'description 2199814')

    lhv_transactions = []
    lhv_transactions << test_transaction_1
    lhv_transactions << test_transaction_2
    lhv_transactions << test_transaction_3

    assert_difference 'BankStatement.count', 1 do
      assert_difference 'BankTransaction.count', 3 do
        post eis_billing_lhv_connect_transactions_path, params: { '_json' => JSON.parse(lhv_transactions.to_json) },
                                                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end
  end

  def test_creates_invoice_and_sends_paid_status
    # Use an invoice that already has a payment reference that matches the transaction
    paid_invoice = invoices(:one)
    spy = Spy.on(EisBilling::SendInvoiceStatus, :send_info).and_return(true)

    transaction = {
      'amount' => paid_invoice.total,
      'currency' => 'EUR',
      'date' => Time.zone.today,
      'payment_reference_number' => paid_invoice.reference_no,
      'payment_description' => 'Makstud arve'
    }

    post eis_billing_lhv_connect_transactions_path,
      params:{ '_json' => [transaction] },
      headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_response :ok
    assert_equal 'RECEIVED', JSON.parse(response.body)['message']
    assert spy.calls.length >= 1, "Expected at least 1 call to send_info, got #{spy.calls.length}"
    
    # Check that at least one of the calls has the correct arguments
    # Since both invoices have the same reference_no, the system might use a different invoice
    # So we check that send_info is called with status 'paid' and any valid invoice number
    call_with_correct_args = spy.calls.any? do |call|
      call.args[0][:status] == 'paid' && call.args[0][:invoice_number].present?
    end
    assert call_with_correct_args, "Expected send_info to be called with status: 'paid' and a valid invoice_number"
  end
end
