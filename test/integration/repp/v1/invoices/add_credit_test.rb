require 'test_helper'

class ReppV1InvoicesAddCreditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    @original_registry_vat_rate = Setting.registry_vat_prc
    eis_response = OpenStruct.new(body: '{"everypay_link":"https://link.test"}')
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  teardown do
    Setting.registry_vat_prc = @original_registry_vat_rate
  end

  def test_generates_add_credit_invoice_with_billing_system
    request_body = {
      invoice: {
        amount: 100,
        description: 'Add credit',
      },
    }
    Setting.registry_vat_prc = 0.1
    ENV['billing_system_integrated'] = 'true'

    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
        .to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
      stub_request(:post, 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice')
        .to_return(status: 200, body: '', headers: {})
    end

    post '/repp/v1/invoices/add_credit', headers: @auth_headers,
                                         params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_not json[:data][:invoice][:paid]
    assert json[:data][:invoice][:payable]
    assert json[:data][:invoice][:cancellable]
    assert_equal json[:data][:invoice][:payment_link], 'https://link.test'
    assert_equal json[:data][:invoice][:total], 110.to_f.to_s
  end

  def test_generates_add_credit_invoice_without_billing_system
    request_body = {
      invoice: {
        amount: 100,
        description: 'Add credit',
      },
    }
    Setting.registry_vat_prc = 0.1
    ENV['billing_system_integrated'] = 'false'

    post '/repp/v1/invoices/add_credit', headers: @auth_headers,
                                         params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_not json[:data][:invoice][:paid]
    assert json[:data][:invoice][:payable]
    assert json[:data][:invoice][:cancellable]
    assert_equal json[:data][:invoice][:total], 110.to_f.to_s
  end

  def test_generates_add_credit_invoice_with_invalid_amount
    request_body = {
      invoice: {
        amount: 0.4,
        description: 'Add credit',
      },
    }
    Setting.minimum_deposit = 0.5

    post '/repp/v1/invoices/add_credit', headers: @auth_headers,
                                         params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal "Amount is too small. Minimum deposit is #{Setting.minimum_deposit} EUR", json[:message]
  end
end