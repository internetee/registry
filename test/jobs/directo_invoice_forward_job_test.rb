require "test_helper"

class DirectoInvoiceForwardJobTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
    @user = registrars(:bestnames)
    travel_to Time.zone.parse('2010-08-06')
  end

  def teardown
    Setting.clear_cache
    Setting.directo_monthly_number_min = 309901
    Setting.directo_monthly_number_max = 309999
    Setting.directo_monthly_number_last = 309901
  end

  def test_xml_is_include_transaction_date
    @invoice.update(total: @invoice.account_activity.bank_transaction.sum)
    @invoice.account_activity.bank_transaction.update(paid_at: Time.zone.now)

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="1" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      request.body.include? 'TransactionDate'
    end.to_return(status: 200, body: response)

    assert_nothing_raised do
      DirectoInvoiceForwardJob.run(monthly: false, dry: false)
    end

    assert_not_empty @invoice.directo_records.first.request
  end

  def test_fails_if_directo_bounds_exceedable
    Setting.clear_cache
    Setting.directo_monthly_number_max = 30990

    assert_raises 'RuntimeError' do
      DirectoInvoiceForwardJob.run(monthly: true, dry: false)
    end
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

      (body.include? '.test registreerimine: 1 aasta') &&
        (body.include? 'Domeenide ettemaks') &&
        (body.include? '309902')
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      DirectoInvoiceForwardJob.run(monthly: true, dry: false)
    end
  end

  def test_monthly_summary_is_delivered_in_english
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    activity.update(activity_type: 'create', price: price)
    @user.update(language: 'en')

    response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <results>
        <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
      </results>
    XML

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      body = CGI.unescape(request.body)
      (body.include? 'test registration') &&
        (body.include? 'Domains prepayment') &&
        (body.include? '309902')
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      DirectoInvoiceForwardJob.run(monthly: true, dry: false)
    end
  end

  def test_multi_year_purchases_have_duration_assigned
    activity = account_activities(:one)
    price = billing_prices(:create_one_year)
    price.update(duration: '3 years')
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
      DirectoInvoiceForwardJob.run(monthly: true, dry: false)
    end
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
      (body.include? 'months')
    end.to_return(status: 200, body: response)

    assert_difference 'Setting.directo_monthly_number_last' do
      DirectoInvoiceForwardJob.run(monthly: true, dry: false)
    end
  end
end
