require 'test_helper'

class ReppV1InvoicesCancelTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_cancels_invoice
    invoice = invoices(:one)
    invoice.account_activity = nil
    assert invoice.cancellable?
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_status')
      .to_return(status: :ok, headers: {})

    put "/repp/v1/invoices/#{invoice.id}/cancel", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    invoice.reload
    assert invoice.cancelled?
    assert json[:data][:invoice].is_a? Hash
  end

  def test_cancels_uncancellable_invoice
    invoice = invoices(:one)
    assert_not invoice.cancellable?

    put "/repp/v1/invoices/#{invoice.id}/cancel", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Invoice status prohibits operation', json[:message]

    invoice.reload
    assert_not invoice.cancelled?
  end
end