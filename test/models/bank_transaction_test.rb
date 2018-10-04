require 'test_helper'

class BankTransactionTest < ActiveSupport::TestCase
  def test_matches_against_invoice_reference_number
    invoices(:valid).update!(number: '2222', total: 10, reference_no: '1111')
    transaction = BankTransaction.new(description: 'invoice #2222', sum: 10, reference_no: '1111')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_does_not_match_against_registrar_reference_number
    registrars(:bestnames).update!(reference_no: '1111')
    transaction = BankTransaction.new(description: 'invoice #2222', sum: 10, reference_no: '1111')

    assert_no_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end
end
