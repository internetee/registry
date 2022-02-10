require 'test_helper'

class ProcessPaymentsTaskTest < ActiveJob::TestCase
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
    @account_activity = account_activities(:one)
    @account = accounts(:cash)

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

  def test_not_raises_error_if_bad_reference
    @payment_description = 'some weird description 252923'
    beneficiary_iban = 'GB33BUKB20201555555555'

    Lhv::ConnectApi.class_eval do
      define_method :credit_debit_notification_messages do
        transaction = OpenStruct.new(amount: @payment_amount,
                                     currency: @payment_currency,
                                     date: @payment_date,
                                     payment_reference_number: @payment_reference_number,
                                     payment_description: @payment_description)
        message = OpenStruct.new(bank_account_iban: beneficiary_iban,
                                 credit_transactions: [transaction])
        [message]
      end
    end

    assert_no_difference 'AccountActivity.count' do
      assert_no_difference 'Invoice.count' do
        assert_no_difference -> {@account.balance} do
          assert_nothing_raised do
            capture_io { run_task }
          end
        end
      end
    end
  end

  def test_cannot_create_new_invoice_if_transaction_binded_to_paid_invoice
    assert_not @invoice.paid?

    @account_activity.update(activity_type: "add_credit", bank_transaction: nil, created_at: Time.zone.today - 1.day, creator_str: 'AdminUser')
    @invoice.update(account_activity: @account_activity, total: @payment_amount)
    assert @invoice.paid?

    assert_no_difference 'AccountActivity.count' do
      assert_no_difference 'Invoice.count' do
        assert_no_difference -> {@account.balance} do
          capture_io { run_task }
        end
      end
    end
  end

  def test_if_invoice_is_overdue_than_48_hours
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number

      Spy.on_instance_method(SendEInvoiceTwoJob, :perform_now).and_return(true)

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      assert_not @invoice.paid?

      @account_activity.update(activity_type: "add_credit", bank_transaction: nil, created_at: Time.zone.today - 3.days, creator_str: 'AdminUser')
      @invoice.update(account_activity: @account_activity, total: @payment_amount)
      assert @invoice.paid?

      assert_difference 'AccountActivity.count' do
        assert_difference 'Invoice.count' do
          capture_io { run_task }
        end
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

  def test_credits_registrar_athout_invoice_beforehand
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}")

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      Spy.on_instance_method(SendEInvoiceTwoJob, :perform_now).and_return(true)

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      registrar = registrars(:bestnames)

      assert_changes -> { registrar.accounts.first.balance } do
        run_task
      end

      assert_changes -> { registrar.invoices.count } do
        run_task
      end
    end
  end

  def test_topup_creates_invoice_with_total_of_transactioned_amount
    registrar = registrars(:bestnames)
    run_task

    assert_equal 0.1, registrar.invoices.last.total
  end

  def test_topup_creates_invoice_and_send_it_as_paid
    if Feature.billing_system_integrated?
      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      registrar = registrars(:bestnames)
      @invoice.payment_orders.destroy_all
      @invoice.destroy

      perform_enqueued_jobs do
        run_task
      end

      invoice = Invoice.last
      assert invoice.paid?
      assert_not invoice.e_invoice_sent_at.blank?

      pdf_source = Invoice::PdfGenerator.new(invoice)
      pdf_source.send(:invoice_html).include?('Receipt date')

      email= ActionMailer::Base.deliveries.last
      assert email.subject.include?('already paid')

      assert_equal 0.1, registrar.invoices.last.total
    end
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
