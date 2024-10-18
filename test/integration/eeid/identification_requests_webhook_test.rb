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

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(
        status: 200,
        body: { access_token: 'token', token_type: 'Bearer', expires_in: 100 }.to_json, headers: {}
      )
    pdf_content = File.read(Rails.root.join('test/fixtures/files/legaldoc.pdf'))
    stub_request(:get, %r{api/ident/v1/identification_requests})
      .to_return(status: 200, body: pdf_content, headers: { 'Content-Type' => 'application/pdf' })

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  test 'should verify contact with valid signature and parameters' do
    @contact.update!(ident_request_sent_at: Time.zone.now - 1.day)
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :ok
    assert_equal({ 'status' => 'success' }, JSON.parse(response.body))
    assert_not_nil @contact.reload.verified_at
    assert_equal @contact.verification_id, '123'
    assert_notify_registrar('Successful Contact Verification')
  end

  test 'should return unauthorized for invalid HMAC signature' do
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => 'invalid_signature' }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid HMAC signature' }, JSON.parse(response.body))
    assert_emails 0
  end

  test 'should return unauthorized for missing parameters' do
    post '/eeid/webhooks/identification_requests', params: { reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid HMAC signature' }, JSON.parse(response.body))
    assert_emails 0
  end

  test 'should handle internal server error gracefully' do
    # Simulate an error in the verify_contact method
    Contact.stub :find_by_code, ->(_) { raise StandardError, 'Simulated error' } do
      post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

      assert_response :internal_server_error
      assert_equal({ 'error' => 'Simulated error' }, JSON.parse(response.body))
      assert_emails 0
    end
  end

  test 'should handle error from ident response' do
    stub_request(:get, %r{api/ident/v1/identification_requests})
      .to_return(status: :not_found, body: { error: 'Proof of identity not found' }.to_json, headers: { 'Content-Type' => 'application/json' })

    @contact.update!(ident_request_sent_at: Time.zone.now - 1.day)
    post '/eeid/webhooks/identification_requests', params: { identification_request_id: '123', reference: @contact.code }, as: :json, headers: { 'X-HMAC-Signature' => @valid_hmac_signature }

    assert_response :internal_server_error
    assert_equal({ 'error' => 'Proof of identity not found' }, JSON.parse(response.body))
    assert_emails 0
    assert_nil @contact.reload.verified_at
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

  private

  def assert_notify_registrar(subject)
    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal [@contact.registrar.email], email.to
    assert_equal subject, email.subject
    assert_equal 1, email.attachments.size
    assert_equal 'proof_of_identity.pdf', email.attachments.first.filename
  end
end
