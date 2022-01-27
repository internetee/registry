require 'test_helper'

class LhvConnectTransactionsIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:unpaid)
    sign_in users(:api_bestnames)
  end

  def test_should_saved_transaction_data
    test_transaction = OpenStruct.new(amount: 0.1,
      currency: 'EUR',
      date: Time.zone.today,
      payment_reference_number: '2199812',
      payment_description: "description 2199812")

    lhv_transactions = []

    3.times do
      lhv_transactions << test_transaction
    end

    assert_difference 'BankStatement.count', 3 do
      assert_difference 'BankTransaction.count', 3 do
        post eis_billing_lhv_connect_transactions_path,  params: { "_json" => JSON.parse(lhv_transactions.to_json) },
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end
  end
end
