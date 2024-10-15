require 'test_helper'

class ReppV1ContactsVerifyTest < ActionDispatch::IntegrationTest
  def setup
    @contact = contacts(:john)
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(
        status: 200,
        body: { access_token: 'token', token_type: 'Bearer', expires_in: 100 }.to_json, headers: {}
      )
    stub_request(:post, %r{api/ident/v1/identification_requests})
      .with(
        body: {
          claims_required: [{ type: 'sub', value: "#{@contact.ident_country_code}#{@contact.ident}" }],
          reference: @contact.code
        }
      ).to_return(status: 200, body: { id: '123' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def test_returns_error_when_not_found
    post '/repp/v1/contacts/verify/nonexistant:code', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_verifies_contact
    post "/repp/v1/contacts/verify/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert contact.present?
    assert contact.ident_request_sent_at
    assert_nil contact.verified_at
    assert_notify_contact('Identification requested')
  end

  def test_handles_non_epp_error
    stub_request(:post, %r{api/ident/v1/identification_requests})
      .to_return(status: :unprocessable_entity, body: { error: 'error' }.to_json, headers: { 'Content-Type' => 'application/json' })

    post "/repp/v1/contacts/verify/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Sending identification request failed', json[:message]
    assert_nil @contact.ident_request_sent_at
    assert_emails 0
  end

  def test_does_not_verify_already_verified_contact
    @contact.update!(verified_at: Time.zone.now - 1.day)
    post "/repp/v1/contacts/verify/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Contact already verified', json[:message]
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post "/repp/v1/contacts/verify/#{@contact.code}", headers: @auth_headers
    post "/repp/v1/contacts/verify/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end

  private

  def assert_notify_contact(subject)
    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal [@contact.email], email.to
    assert_equal subject, email.subject
  end
end
