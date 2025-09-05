require 'test_helper'

class AdminAreaBankStatementsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @bank_statement = bank_statements(:one)
  end

  def test_index_page_accessible
    get admin_bank_statements_path
    assert_response :success
    assert_includes response.body, 'Bank statements'
  end

  def test_creates_bank_statement
    params = {
      bank_statement: {
        bank_code: '9876',
        iban: 'GB82WEST12345698765432'
      }
    }

    assert_difference 'BankStatement.count', +1 do
      post admin_bank_statements_path, params: params
    end

    statement = BankStatement.last
    assert_redirected_to admin_bank_statement_path(statement)
    follow_redirect!
    assert_response :success
    assert_includes flash[:notice], I18n.t('record_created')
  end

  def test_bind_invoices_sets_flash_when_nothing_binded
    post bind_invoices_admin_bank_statement_path(@bank_statement)

    assert_redirected_to admin_bank_statement_path(@bank_statement)
    follow_redirect!
    assert_response :success
    assert_equal I18n.t('no_invoices_were_binded'), flash[:alert]
  end
end 
