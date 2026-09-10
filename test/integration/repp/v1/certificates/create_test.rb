require 'test_helper'
require 'openssl'

class ReppV1CertificatesCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
    
    @user.registrar.update!(address_country_code: 'ET',vat_rate: 22)
  end

  def test_creates_new_api_user_certificate_and_informs_admins
    original_username = @user.username
    @user.update!(username: 'host.ee') && @user.reload

    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    headers = { 'Authorization' => "Basic #{token}" }

    assert_difference('Certificate.count') do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post repp_v1_certificates_path, headers: headers, params: request_body

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
      end
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    
    @user.update!(username: original_username)
  end

  def test_returns_error_when_csr_cn_does_not_match_api_username
    body = request_body(username: 'wrong_user')

    post repp_v1_certificates_path, headers: @auth_headers, params: body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_includes json[:message], I18n.t(:csr_cn_mismatch)
  end

  def test_returns_error_when_csr_country_does_not_match_registrar_country
    body = request_body(country: 'LV')

    post repp_v1_certificates_path, headers: @auth_headers, params: body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_includes json[:message], I18n.t(:csr_country_mismatch)
  end

  def test_return_error_when_invalid_certificate
    request_body = {
      certificate: {
        api_user_id: @user.id,
        csr: {
          body: 'invalid',
          type: 'csr',
        },
      },
    }

    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? I18n.t(:crt_or_csr_must_be_present)
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end

  def request_body(username: @user.username, country: @user.registrar.address_country_code)
    csr_body = Base64.strict_encode64(generate_csr_pem(username: username, country: country))

    {
      certificate: {
        api_user_id: @user.id,
        csr: {
          body: csr_body,
          type: 'csr',
        },
      },
    }
  end

  def generate_csr_pem(username:, country:)
    key = OpenSSL::PKey::RSA.new(2048)
    request = OpenSSL::X509::Request.new
    request.version = 0
    request.subject = OpenSSL::X509::Name.new([
      ['CN', username, OpenSSL::ASN1::UTF8STRING],
      ['C', country.to_s.upcase, OpenSSL::ASN1::PRINTABLESTRING],
    ])
    request.public_key = key.public_key
    request.sign(key, OpenSSL::Digest.new('SHA256'))
    request.to_pem
  end
end
