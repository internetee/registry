require 'test_helper'

class RegistrantApiCorsHeadersTest < ApplicationIntegrationTest
  def test_returns_200_response_code_for_options_request
    process :options, api_v1_registrant_auth_eid_path,
            headers: { 'Origin' => 'https://example.com' }
    assert_equal('200', response.code)
  end

  def test_returns_expected_headers_for_options_requests
    process :options, api_v1_registrant_auth_eid_path, headers: { 'Origin' => 'https://example.com' }

    assert_equal('https://example.com', response.headers['Access-Control-Allow-Origin'])
    assert_equal('POST, GET, PUT, PATCH, DELETE, OPTIONS',
                 response.headers['Access-Control-Allow-Methods'])
    assert_equal('Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, ' \
                 'X-User-Token, X-User-Email',
               response.headers['Access-Control-Allow-Headers'])
    assert_equal('3600', response.headers['Access-Control-Max-Age'])
  end

  def test_returns_empty_body
    process :options, api_v1_registrant_auth_eid_path, headers: { 'Origin' => 'https://example.com' }
    assert_equal('', response.body)
  end

  def test_it_returns_cors_headers_for_other_requests
    post '/api/v1/registrant/auth/eid', headers: { 'Origin' => 'https://example.com' }
    assert_equal('https://example.com', response.headers['Access-Control-Allow-Origin'])

    get '/api/v1/registrant/contacts', headers: { 'Origin' => 'https://example.com' }
    assert_equal('https://example.com', response.headers['Access-Control-Allow-Origin'])
  end
end
