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

  def test_underpayment_is_not_matched_with_invoice
    invoices(:valid).update!(number: '2222', total: 10)
    transaction = BankTransaction.new(sum: 9)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Invoice and transaction sums do not match')
  end

  def test_overpayment_is_not_matched_with_invoice
    invoices(:valid).update!(number: '2222', total: 10)
    transaction = BankTransaction.new(sum: 11)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Invoice and transaction sums do not match')
  end

  def test_cancelled_invoice_is_not_matched
    invoices(:valid).update!(number: '2222', total: 10, cancelled_at: '2010-07-05')
    transaction = BankTransaction.new(sum: 10)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Cannot bind cancelled invoice')
  end
end
