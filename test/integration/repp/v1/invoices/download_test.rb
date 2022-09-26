require 'test_helper'

class ReppV1InvoicesDownloadTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_invoice_as_pdf
    invoice = @user.registrar.invoices.first

    get "/repp/v1/invoices/#{invoice.id}/download", headers: @auth_headers

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "attachment; filename=\"Invoice-2.pdf\"; filename*=UTF-8''Invoice-2.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end