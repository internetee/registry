require 'test_helper'

class AdminAreaBankTransactionsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @bank_statement = bank_statements(:one)
    @bank_transaction = bank_transactions(:one)
  end

  def test_new_page_accessible
    get new_admin_bank_statement_bank_transaction_path(@bank_statement)
    assert_response :success
  end

  def test_creates_bank_transaction
    params = {
      bank_transaction: {
        description: 'Payment for invoice',
        sum: '50.00',
        currency: 'EUR'
      }
    }

    assert_difference 'BankTransaction.count', +1 do
      post admin_bank_statement_bank_transactions_path(@bank_statement), params: params
    end

    transaction = BankTransaction.last
    assert_redirected_to admin_bank_transaction_path(transaction)
    follow_redirect!
    assert_response :success
    assert_includes flash[:notice], I18n.t('record_created')
  end

  def test_bind_invoice_sets_flash_when_invoice_not_found
    patch bind_admin_bank_transaction_path(@bank_transaction), params: { invoice_no: 'INVALID123' }

    assert_response :success
    assert_equal I18n.t('failed_to_create_record'), flash[:alert]
  end

  def test_updates_bank_transaction
    new_description = 'Updated description'

    patch admin_bank_transaction_path(@bank_transaction), params: {
      bank_transaction: {
        description: new_description,
        sum: '1,50'
      }
    }

    assert_redirected_to admin_bank_transaction_path(@bank_transaction)
    follow_redirect!
    assert_response :success
    assert_equal I18n.t('record_updated'), flash[:notice]

    @bank_transaction.reload
    assert_equal new_description, @bank_transaction.description
    assert_in_delta 1.5, @bank_transaction.sum.to_f, 0.0001
  end
end 
