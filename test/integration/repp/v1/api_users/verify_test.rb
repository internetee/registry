# frozen_string_literal: true

require 'test_helper'

class ReppV1ApiUsersVerifyTest < ActionDispatch::IntegrationTest
  def setup
    @api_user = users(:api_bestnames_epp)
    @api_user.update!(email: 'verify@example.test', subject: nil)
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(
        status: 200,
        body: { access_token: 'token', token_type: 'Bearer', expires_in: 100 }.to_json, headers: {}
      )
    stub_request(:post, %r{api/ident/v1/identification_requests})
      .with(
        body: hash_including(
          'claims_required' => [{ 'type' => 'sub', 'value' => '' }],
          'reference' => @api_user.uuid
        )
      ).to_return(status: 200, body: { id: '123', link: 'http://link' }.to_json,
                  headers: { 'Content-Type' => 'application/json' })
  end

  def test_verifies_api_user_with_discovery_claims
    post "/repp/v1/api_users/verify/#{@api_user.id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    @api_user.reload
    assert @api_user.ident_request_sent_at.present?
    assert_nil @api_user.verified_at
    assert_emails 1
    assert_equal ['verify@example.test'], ActionMailer::Base.deliveries.last.to
  end

  def test_returns_error_without_email
    @api_user.update!(email: nil)

    post "/repp/v1/api_users/verify/#{@api_user.id}", headers: @auth_headers

    assert_response :bad_request
    assert_nil @api_user.reload.ident_request_sent_at
    assert_emails 0
  end

  def test_verifies_api_user_with_existing_subject
    @api_user.update!(subject: 'EE60001019906', country_code: 'EE')
    stub_request(:post, %r{api/ident/v1/identification_requests})
      .with(
        body: hash_including(
          'claims_required' => [{ 'type' => 'sub', 'value' => 'EE60001019906' }]
        )
      ).to_return(status: 200, body: { id: '123', link: 'http://link' }.to_json,
                  headers: { 'Content-Type' => 'application/json' })

    post "/repp/v1/api_users/verify/#{@api_user.id}", headers: @auth_headers

    assert_response :ok
    assert @api_user.reload.ident_request_sent_at.present?
  end
end
