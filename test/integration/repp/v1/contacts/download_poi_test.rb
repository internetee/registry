require 'test_helper'

class ReppV1ContactsDownloadPoiTest < ActionDispatch::IntegrationTest
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
    pdf_content = File.read(Rails.root.join('test/fixtures/files/legaldoc.pdf'))
    stub_request(:get, %r{api/ident/v1/identification_requests})
      .to_return(status: 200, body: pdf_content, headers: { 'Content-Type' => 'application/pdf' })
  end

  def test_returns_error_when_not_found
    get '/repp/v1/contacts/download_poi/nonexistant:code', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_downloads_poi_for_contact
    @contact.update!(verified_at: Time.zone.now - 1.day, verification_id: '123')
    get "/repp/v1/contacts/download_poi/#{@contact.code}", headers: @auth_headers

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "inline; filename=\"proof_of_identity_123.pdf\"; filename*=UTF-8''proof_of_identity_123.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_handles_non_epp_error
    stub_request(:get, %r{api/ident/v1/identification_requests})
      .to_return(
        status: :not_found,
        body: { error: 'Proof of identity not found' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    get "/repp/v1/contacts/download_poi/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Proof of identity not found', json[:message]
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    get "/repp/v1/contacts/download_poi/#{@contact.code}", headers: @auth_headers
    get "/repp/v1/contacts/download_poi/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
