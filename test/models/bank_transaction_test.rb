require 'test_helper'

class BankTransactionTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
    @invoice = invoices(:one)
  end

  def test_matches_against_invoice_nubmber_and_reference_number
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    transaction = BankTransaction.new(description: 'invoice #2222', sum: 10, reference_no: '1234567')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_binds_if_this_sum_invoice_already_present
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    another_invoice = @invoice.dup
    another_invoice.save(validate: false)
    another_invoice.update(reference_no: '7654321', number: '2221')

    another_item = @invoice.items.first.dup
    another_item.invoice = another_invoice
    another_item.save
    another_invoice.reload

    first_transaction = BankTransaction.new(sum: 10,
                                            description: 'Order nr 1 from registrar 1234567 second number 2345678')

    first_transaction.create_activity(another_invoice.buyer, another_invoice)

    transaction = BankTransaction.new(sum: 10,
                                      description: 'Order nr 1 from registrar 1234567 second number 2345678')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_binds_if_this_sum_cancelled_invoice_already_present
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    another_invoice = @invoice.dup
    another_invoice.save(validate: false)


    another_item = @invoice.items.first.dup
    another_item.invoice = another_invoice

    another_item.save
    another_invoice.reload
    another_invoice.update(reference_no: '1234567', number: '2221', cancelled_at: Time.zone.now)

    transaction = BankTransaction.new(sum: 10,
                                      description: 'Order nr 1 from registrar 1234567 second number 2345678')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_marks_the_first_one_as_paid_if_same_sum
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    another_invoice = @invoice.dup
    another_invoice.save(validate: false)
    another_invoice.update(reference_no: '7654321', number: '2221')

    another_item = @invoice.items.first.dup
    another_item.invoice = another_invoice
    another_item.save
    another_invoice.reload

    transaction = BankTransaction.new(sum: 10,
                                      description: 'Order nr 1 from registrar 1234567 second number 2345678')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end

    @invoice.reload
    another_invoice.reload
    assert(@invoice.paid?)
    assert_not(another_invoice.paid?)
  end

  def test_matches_against_invoice_nubmber_and_reference_number_in_description
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    transaction = BankTransaction.new(sum: 10,
                                      description: 'Order nr 1 from registrar 1234567 second number 2345678')

    assert_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_no_errors_if_no_valid_refnumber_in_description
    create_payable_invoice(number: '2222', total: 10, reference_no: '1234567')
    transaction = BankTransaction.new(sum: 10,
                                      description: 'Order nr 1 from registrar 123456')

    assert_no_difference 'AccountActivity.count' do
      assert_nothing_raised do
        transaction.autobind_invoice
      end
    end
  end

  def test_resets_pending_registrar_balance_reload
    registrar = registrar_with_pending_balance_auto_reload
    create_payable_invoice(number: '2222', total: 10, reference_no: '1111')
    transaction = BankTransaction.new(description: 'invoice #2222', sum: 10, reference_no: '1111')

    transaction.autobind_invoice
    registrar.reload

    assert_nil registrar.settings['balance_auto_reload']['pending']
  end

  def test_does_not_match_against_registrar_reference_number
    @registrar.update!(reference_no: '1111')
    transaction = BankTransaction.new(description: 'invoice #2222', sum: 10, reference_no: '1111')

    assert_no_difference 'AccountActivity.count' do
      transaction.autobind_invoice
    end
  end

  def test_underpayment_is_not_matched_with_invoice
    create_payable_invoice(number: '2222', total: 10)
    transaction = BankTransaction.new(sum: 9)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Invoice and transaction sums do not match')
  end

  def test_overpayment_is_not_matched_with_invoice
    create_payable_invoice(number: '2222', total: 10)
    transaction = BankTransaction.new(sum: 11)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Invoice and transaction sums do not match')
  end

  def test_cancelled_invoice_is_not_matched
    @invoice.update!(account_activity: nil, number: '2222', total: 10, cancelled_at: '2010-07-05')
    transaction = BankTransaction.new(sum: 10)

    assert_no_difference 'AccountActivity.count' do
      transaction.bind_invoice('2222')
    end
    assert transaction.errors.full_messages.include?('Cannot bind cancelled invoice')
  end

  def test_assumes_7_digit_number_is_reference_no_in_desc
    statement = BankTransaction.new
    statement.description = 'number 1234567 defo valid'
    assert_equal '1234567', statement.parsed_ref_number
  end

  def test_determines_correct_ref_no_from_description
    statement = BankTransaction.new
    ref_no = registrars(:bestnames).reference_no
    statement.description = "invoice 123 125 55 4521 #{ref_no} 7541 defo valid"
    assert_equal ref_no.to_s, statement.parsed_ref_number
  end

  def test_parsed_ref_no_returns_nil_if_ref_not_found
    statement = BankTransaction.new
    statement.description = "all invalid 12 123 55 77777 --"
    assert_nil statement.parsed_ref_number
  end
  private

  def create_payable_invoice(attributes)
    payable_attributes = { account_activity: nil }
    @invoice.update!(payable_attributes.merge(attributes))
    @invoice
  end

  def registrar_with_pending_balance_auto_reload
    @registrar.update!(settings: { balance_auto_reload: { pending: true } })
    @registrar
  end
end
