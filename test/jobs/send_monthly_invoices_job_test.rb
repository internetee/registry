require 'test_helper'

class SendMonthlyInvoicesJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = registrars(:bestnames)
    @date = Time.zone.parse('2010-08-06')
    travel_to @date
    ActionMailer::Base.deliveries.clear
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear
  end

  def teardown
    Setting.directo_monthly_number_min = 309_901
    Setting.directo_monthly_number_max = 309_999
    Setting.directo_monthly_number_last = 309_901
    EInvoice.provider = EInvoice::Providers::TestProvider.new
    EInvoice::Providers::TestProvider.deliveries.clear
  end

  def test_fails_if_directo_bounds_exceedable
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)

    Setting.directo_monthly_number_max = 30_991

    assert_no_difference 'Directo.count' do
      assert_raises 'RuntimeError' do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    assert_nil Invoice.find_by_monthly_invoice(true)
    assert_emails 0
    assert_equal 0, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_monthly_summary_is_not_delivered_if_dry
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    assert_difference 'Setting.directo_monthly_number_last' do
      assert_no_difference 'Directo.count' do
        SendMonthlyInvoicesJob.perform_now(dry: true)
      end
    end

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
    refute invoice.in_directo
    assert invoice.e_invoice_sent_at.blank?

    assert_emails 0
    assert_equal 0, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_monthly_summary_is_delivered_if_invoice_already_exists
    @monthly_invoice = invoices(:one)
    @monthly_invoice.update(number: 309_902, monthly_invoice: true,
                            issue_date: @date.last_month.end_of_month,
                            due_date: @date.last_month.end_of_month,
                            metadata: metadata,
                            in_directo: false,
                            e_invoice_sent_at: nil)

    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)

      (body.include? '.test registreerimine: 1 aasta(t)') &&
        (body.include? 'Domeenide ettemaks') &&
        (body.include? '309902')
    end.to_return(status: 200, body: response)

    assert_no_difference 'Setting.directo_monthly_number_last' do
      assert_difference('Directo.count', 1) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
    assert invoice.in_directo
    assert_not invoice.e_invoice_sent_at.blank?

    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal ['billing@bestnames.test'], email.to
    assert_equal 'Invoice no. 309902 (monthly invoice)', email.subject
    assert email.attachments['invoice-309902.pdf']

    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_monthly_summary_is_delivered_in_estonian
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update!(activity_type: 'create', price: price)
    @user.update(language: 'et')

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)

      (body.include? '.test registreerimine: 1 aasta(t)') &&
        (body.include? 'Domeenide ettemaks') &&
        (body.include? '309902')
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      assert_difference('Directo.count', 1) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
    assert invoice.in_directo
    assert_not invoice.e_invoice_sent_at.blank?

    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal ['billing@bestnames.test'], email.to
    assert_equal 'Invoice no. 309902 (monthly invoice)', email.subject
    assert email.attachments['invoice-309902.pdf']

    assert_equal 1, EInvoice::Providers::TestProvider.deliveries.count
  end

  def test_multi_year_purchases_have_duration_assigned
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    price.update(duration: 3.years)
    activity.update(activity_type: 'create', price: price)

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'StartDate') && (body.include? 'EndDate')
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      SendMonthlyInvoicesJob.perform_now
    end

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
    assert invoice.in_directo
    assert_not invoice.e_invoice_sent_at.blank?
  end

  def test_monthly_duration_products_are_present_in_summary
    activity = account_activities(:one)
    price = billing_prices(:create_one_month)
    activity.update(activity_type: 'create', price: price)

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)
      body.include? 'month(s)'
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      SendMonthlyInvoicesJob.perform_now
    end

    invoice = Invoice.last
    assert_equal 309_902, invoice.number
    assert invoice.in_directo
    assert_not invoice.e_invoice_sent_at.blank?
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

    response = <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <results>
      <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
    </results>
    XML

    first_registrar_stub = stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'StartDate') && (body.include? 'EndDate') && (body.include? 'bestnames')
    end.to_return(status: 200, body: response)

    second_registrar_stub = stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'StartDate') && (body.include? 'EndDate') && (body.include? 'goodnames')
    end.to_return(status: 200, body: response)

    assert_difference('Invoice.count', 2) do
      assert_difference('Directo.count', 2) do
        SendMonthlyInvoicesJob.perform_now
      end
    end

    assert_requested first_registrar_stub
    assert_requested second_registrar_stub

    assert_emails 2
    assert_equal 2, EInvoice::Providers::TestProvider.deliveries.count
  end

  private

  def metadata
    {
      "items" => [
        { "description" => "Domeenide registreerimine - Juuli 2010" },
        { "product_id" => nil, "quantity" => 1, "unit" => "tk", "price" => 10.0, "description" => ".test registreerimine: 1 aasta(t)" },
        { "product_id" => "ETTEM06", "description" => "Domeenide ettemaks", "quantity" => -1, "price" => 10.0, "unit" => "tk" },
      ],
    }
  end
end