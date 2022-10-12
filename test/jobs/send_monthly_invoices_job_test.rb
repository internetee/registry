require 'test_helper'

class SendMonthlyInvoicesJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = registrars(:bestnames)
    @date = Time.zone.parse('2010-08-06')
    travel_to @date
    ActionMailer::Base.deliveries.clear

    @response = { 'message' => 'Invoice data received' }.to_json
    @monthly_invoice_numbers_generator_url = 'https://eis_billing_system:3000/api/v1/invoice_generator/monthly_invoice_numbers_generator'
    @directo_url = 'https://eis_billing_system:3000/api/v1/directo/directo'
    @e_invoice_url = 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice'
  end

  def test_fails_if_directo_bounds_exceedable
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :not_implemented, body: { error: 'out of range' }.to_json, headers: {})

    SendMonthlyInvoicesJob.perform_now

    assert_nil Invoice.find_by_monthly_invoice(true)
    assert_emails 0
  end

  def test_monthly_summary_is_not_delivered_if_dry
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :ok, body: { invoice_numbers: [309_902] }.to_json, headers: {})

    SendMonthlyInvoicesJob.perform_now(dry: true)

    invoice = Invoice.find_by_monthly_invoice(true)
    assert_equal 309_902, invoice.number
    refute invoice.sent_at
    refute invoice.in_directo
    assert invoice.e_invoice_sent_at.blank?

    assert_emails 0
  end

  def test_monthly_summary_is_delivered_if_invoice_already_exists
    @monthly_invoice = invoices(:one)
    @monthly_invoice.update(number: 309_902, monthly_invoice: true,
                            issue_date: @date.last_month.end_of_month,
                            due_date: @date.last_month.end_of_month,
                            metadata: metadata,
                            in_directo: false,
                            sent_at: nil,
                            e_invoice_sent_at: nil)

    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)

      (body.include? '.test registreerimine: 1 aasta(t)') &&
        (body.include? 'Domeenide ettemaks') &&
        (body.include? '309902')
    end.to_return(status: 200, body: @response)

    assert_enqueued_jobs 1, only: SendEInvoiceJob do
      assert_no_difference('Invoice.count') do
        SendMonthlyInvoicesJob.perform_now
      end
    end
    @monthly_invoice.reload

    assert_not_nil @monthly_invoice.sent_at
    assert_emails 1
  end

  def test_monthly_summary_is_delivered_in_estonian
    activity = account_activities(:one)
    price = billing_prices(:create_one_month)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)

      (body.include? '.test registreerimine: 3 kuu(d)') &&
        (body.include? 'Domeenide ettemaks') &&
        (body.include? '309902')
    end.to_return(status: 200, body: @response)

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :ok, body: { invoice_numbers: [309_902] }.to_json, headers: {})

    stub_request(:post, @e_invoice_url)
      .to_return(status: 200, body: @response, headers: {})

    assert_enqueued_jobs 1, only: SendEInvoiceJob do
      assert_difference('Invoice.count', 1) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    perform_enqueued_jobs

    invoice = Invoice.last
    assert_equal 309_902, invoice.number

    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal ['billing@bestnames.test'], email.to
    assert_equal 'Invoice no. 309902 (monthly invoice)', email.subject
    assert email.attachments['invoice-309902.pdf']
  end

  def test_multi_year_purchases_have_duration_assigned
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    price.update(duration: 3.years)
    activity.update(activity_type: 'create', price: price)

    stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'start_date') && (body.include? 'end_date')
    end.to_return(status: 200, body: @response)

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :ok, body: { invoice_numbers: [309_902] }.to_json, headers: {})

    stub_request(:post, @e_invoice_url)
      .to_return(status: 200, body: @response, headers: {})

    assert_enqueued_jobs 1, only: SendEInvoiceJob do
      assert_difference('Invoice.count', 1) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    perform_enqueued_jobs

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
  end

  def test_monthly_duration_products_are_present_in_summary
    activity = account_activities(:one)
    price = billing_prices(:create_one_month)
    activity.update(activity_type: 'create', price: price)

    stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)
      body.include? 'month(s)'
    end.to_return(status: 200, body: @response)

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :ok, body: { invoice_numbers: [309_902] }.to_json, headers: {})

    stub_request(:post, @e_invoice_url)
      .to_return(status: 200, body: @response, headers: {})

    assert_enqueued_jobs 1, only: SendEInvoiceJob do
      assert_difference('Invoice.count', 1) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    perform_enqueued_jobs

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
  end

  def test_sends_each_monthly_invoice_separately
    WebMock.reset!

    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    price.update(duration: 3.years)
    activity.update(activity_type: 'create', price: price)

    # Creating account activity for second action
    another_activity = activity.dup
    another_activity.account = accounts(:two)

    AccountActivity.skip_callback(:create, :after, :update_balance)
    another_activity.created_at = Time.zone.parse('2010-07-05 10:00')
    another_activity.save
    AccountActivity.set_callback(:create, :after, :update_balance)

    first_registrar_stub = stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'start_date') && (body.include? 'end_date') && (body.include? 'bestnames')
    end.to_return(status: 200, body: @response)

    second_registrar_stub = stub_request(:post, @directo_url).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'start_date') && (body.include? 'end_date') && (body.include? 'goodnames')
    end.to_return(status: 200, body: @response)

    stub_request(:post, @e_invoice_url).with do |request|
      body = CGI.unescape(request.body)
      (body.include? '309902') && (body.include? 'goodnames')
    end.to_return(status: 200, body: @response)

    stub_request(:post, @e_invoice_url).with do |request|
      body = CGI.unescape(request.body)
      (body.include? '309903') && (body.include? 'bestnames')
    end.to_return(status: 200, body: @response)

    stub_request(:post, @monthly_invoice_numbers_generator_url)
      .to_return(status: :ok, body: { invoice_numbers: [309_902, 309_903] }.to_json, headers: {})

    assert_enqueued_jobs 2, only: SendEInvoiceJob do
      assert_difference('Invoice.count', 2) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    perform_enqueued_jobs

    assert_requested first_registrar_stub
    assert_requested second_registrar_stub

    assert_emails 2
  end

  private

  def metadata
    {
      'items' => [
        { 'description' => 'Domeenide registreerimine - Juuli 2010' },
        { 'product_id' => nil, 'quantity' => 1, 'unit' => 'tk', 'price' => 10.0,
          'description' => '.test registreerimine: 1 aasta(t)',
          'duration_in_years' => 1 },
        { 'product_id' => 'ETTEM06', 'description' => 'Domeenide ettemaks', 'quantity' => -1,
          'price' => 10.0, 'unit' => 'tk' },
      ],
    }
  end
end