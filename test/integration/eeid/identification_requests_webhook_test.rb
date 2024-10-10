require 'test_helper'

class Eeid::IdentificationRequestsWebhookTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)
    @secret = 'valid_secret'
    ENV['ident_service_client_secret'] = @secret
    payload = {
      identification_request_id: '123',
      reference: @contact.code
    }
    @valid_hmac_signature = OpenSSL::HMAC.hexdigest('SHA256', @secret, payload.to_json)

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  test 'should verify contact with valid signature and parameters' do
    @contact.update!(ident_request_sent_at: Time.zone.now - 1.day)
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :ok
    assert_equal({ 'status' => 'success' }, JSON.parse(response.body))
    assert_not_nil @contact.reload.verified_at
  end

  test 'should return unauthorized for invalid HMAC signature' do
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => 'invalid_signature' }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid HMAC signature' }, JSON.parse(response.body))
  end

  test 'should return unauthorized for missing parameters' do
    post '/eeid/webhooks/identification_requests', params: { reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid HMAC signature'  }, JSON.parse(response.body))
  end

  test 'should handle internal server error gracefully' do
    # Simulate an error in the verify_contact method
    Contact.stub :find_by_code, ->(_) { raise StandardError, 'Simulated error' } do
      post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

      assert_response :internal_server_error
      assert_equal({ 'error' => 'Internal Server Error' }, JSON.parse(response.body))
    end
  end

  test 'returns error response if throttled' do
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :bad_request
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
