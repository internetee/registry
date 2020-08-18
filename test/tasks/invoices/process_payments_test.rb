require 'test_helper'

class ProcessPaymentsTaskTest < ActiveSupport::TestCase
  setup do
    @payment_amount = payment_amount = 0.1
    @payment_currency = payment_currency = 'EUR'
    @payment_date = payment_date = Date.parse('2010-07-05')
    @payment_reference_number = payment_reference_number = '13'
    @payment_description = payment_description = @invoice_number = '1234'
    beneficiary_iban = 'GB33BUKB20201555555555'

    @invoice = create_payable_invoice(number: @invoice_number,
                                      total: payment_amount,
                                      currency: @payment_currency,
                                      reference_no: @payment_reference_number)
    Setting.registry_iban = beneficiary_iban

    Lhv::ConnectApi.class_eval do
      define_method :credit_debit_notification_messages do
        transaction = OpenStruct.new(amount: payment_amount,
                                     currency: payment_currency,
                                     date: payment_date,
                                     payment_reference_number: payment_reference_number,
                                     payment_description: payment_description)
        message = OpenStruct.new(bank_account_iban: beneficiary_iban,
                                 credit_transactions: [transaction])
        [message]
      end
    end
  end

  def test_doubles_are_valid
    assert Lhv::ConnectApi.method_defined?(:credit_debit_notification_messages)
    assert Lhv::ConnectApi::Messages::CreditDebitNotification.method_defined?(:bank_account_iban)
    assert Lhv::ConnectApi::Messages::CreditDebitNotification.method_defined?(:credit_transactions)
  end

  def test_saves_transactions
    assert_difference 'BankStatement.count' do
      assert_difference 'BankTransaction.count' do
        capture_io { run_task }
      end
    end
    transaction = BankTransaction.last
    assert_equal @payment_amount, transaction.sum
    assert_equal @payment_currency, transaction.currency
    assert_equal @payment_date, transaction.paid_at.to_date
    assert_equal @payment_reference_number, transaction.reference_no
    assert_equal @payment_description, transaction.description
  end

  def test_marks_matched_invoice_as_paid
    assert @invoice.unpaid?

    capture_io { run_task }
    @invoice.reload

    assert @invoice.paid?
  end

  def test_attaches_paid_payment_order_to_invoice
    assert @invoice.unpaid?

    capture_io { run_task }
    @invoice.reload

    payment_order = @invoice.payment_orders.last
    assert_equal 'PaymentOrders::SystemPayment', payment_order.type
    assert payment_order.paid?
  end

  def test_attaches_failed_payment_order_to_invoice
    assert @invoice.unpaid?
    account = accounts(:cash)
    account.update!(registrar: registrars(:goodnames))

    capture_io { run_task }
    @invoice.reload

    payment_order = @invoice.payment_orders.last
    assert_equal 'PaymentOrders::SystemPayment', payment_order.type
    assert payment_order.failed?
  end

  def test_output
    assert_output "Transactions processed: 1\n" do
      run_task
    end
  end

  def test_parses_keystore_properly
    assert_nothing_raised do
      run_task
    end
  end

  private

  def run_task
    Rake::Task['invoices:process_payments'].execute
  end

  def create_payable_invoice(attributes = {})
    invoice = invoices(:one)
    invoice.update!({ account_activity: nil, cancelled_at: nil }.merge(attributes))
    invoice
  end
end
