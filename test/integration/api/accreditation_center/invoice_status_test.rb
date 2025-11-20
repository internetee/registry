require 'test_helper'

class InvoiceStatusTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    @header = { 'Authorization' => "Basic #{generate_base64}" }

    # Enable the accreditation endpoints feature for testing
    ENV['allow_accr_endspoints'] = 'true'
  end

  def teardown
    # Clean up environment variable
    ENV.delete('allow_accr_endspoints')
    super
  end

  def test_should_return_cancelled_invoices
    date_now = Time.now

    get '/api/v1/accreditation_center/invoice_status', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:invoices].count, 0

    invoice = @user.registrar.invoices.last
    invoice.update(cancelled_at: date_now)

    get '/api/v1/accreditation_center/invoice_status', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:invoices].count, 1
  end

  def test_return_error_without_authentication
    get '/api/v1/accreditation_center/invoice_status'
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response 401
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  def test_return_forbidden_when_feature_disabled
    # Disable the feature
    ENV['allow_accr_endspoints'] = 'false'

    get '/api/v1/accreditation_center/invoice_status', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:errors], 'Accreditation Center API is not allowed'
    assert_equal response.status, 403
  end

  def test_return_successful_with_no_cancelled_invoices
    get '/api/v1/accreditation_center/invoice_status', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:invoices].count, 0
  end

  private

  def generate_base64
    Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
  end
end