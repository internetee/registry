require 'test_helper'

class ReppV1InvoicesSendTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_sends_invoice_to_recipient
    invoice = invoices(:one)
    recipient = 'donaldtrump@yandex.ru'
    request_body = {
      invoice: {
        id: invoice.id,
        recipient: recipient,
      },
    }
    post "/repp/v1/invoices/#{invoice.id}/send_to_recipient", headers: @auth_headers,
                                                              params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal 1, invoice.number

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal json[:data][:invoice][:id], invoice.id
    assert_equal json[:data][:invoice][:recipient], recipient
    email = ActionMailer::Base.deliveries.last
    assert_emails 1
    assert_equal [recipient], email.to
    assert_equal 'Invoice no. 1', email.subject
    assert email.attachments['invoice-1.pdf']
  end
end