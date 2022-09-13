require 'test_helper'

class LhvConnectTransactionsIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:unpaid)
    sign_in users(:api_bestnames)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_should_saved_transaction_data
    test_transaction1 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199812',
                          payment_description: 'description 2199812' }

    test_transaction2 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199813',
                          payment_description: 'description 2199813' }

    test_transaction3 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199814',
                          payment_description: 'description 2199814' }

    lhv_transactions = []
    lhv_transactions << test_transaction1
    lhv_transactions << test_transaction2
    lhv_transactions << test_transaction3

    assert_difference 'BankStatement.count', 1 do
      assert_difference 'BankTransaction.count', 3 do
        post eis_billing_lhv_connect_transactions_path, params: { '_json' => JSON.parse(lhv_transactions.to_json) },
                                                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end
  end

  def test_should_ignore_banklink_transactions
    test_transaction1 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199812',
                          payment_description: 'billing.internet.ee/EE, st961268, 2199812' }

    test_transaction2 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199813',
                          payment_description: 'description 2199813' }

    test_transaction3 = { amount: 0.1,
                          currency: 'EUR',
                          date: Time.zone.today,
                          payment_reference_number: '2199814',
                          payment_description: 'description 2199814' }

    lhv_transactions = []
    lhv_transactions << test_transaction1
    lhv_transactions << test_transaction2
    lhv_transactions << test_transaction3

    assert_difference 'BankStatement.count', 1 do
      assert_difference 'BankTransaction.count', 2 do
        post eis_billing_lhv_connect_transactions_path, params: { '_json' => JSON.parse(lhv_transactions.to_json) },
                                                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end
  end
end
