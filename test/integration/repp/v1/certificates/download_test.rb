require 'test_helper'

class ReppV1CertificatesDownloadTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @certificate = certificates(:api)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_returns_error_when_not_found
    get download_repp_v1_api_user_certificate_path(id: 'wrong', api_user_id: @user.id, type: 'crt'), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_shows_existing_api_user_certificate
    get download_repp_v1_api_user_certificate_path(api_user_id: @user.id, id: @certificate, type: 'crt'), headers: @auth_headers

    expected_filename = "#{@user.username}_#{Time.zone.today.strftime('%y%m%d')}_portal.crt.pem"

    assert_response :success
    assert_equal 'application/octet-stream', response.content_type
    assert response.headers['Content-Disposition'].include? "attachment; filename=\"#{expected_filename}\""
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    get download_repp_v1_api_user_certificate_path(api_user_id: @user.id, id: @certificate, type: 'crt'), headers: @auth_headers
    get download_repp_v1_api_user_certificate_path(api_user_id: @user.id, id: @certificate, type: 'crt'), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
