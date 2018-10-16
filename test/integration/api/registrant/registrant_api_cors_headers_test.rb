require 'test_helper'

class RegistrantApiCorsHeadersTest < ApplicationIntegrationTest
  def test_returns_200_response_code_for_options_request
    options '/api/v1/registrant/auth/eid', {}

    assert_equal('200', response.code)
  end

  def test_returns_expected_headers_for_options_requests
    options '/api/v1/registrant/auth/eid', {}, { 'Origin' => 'https://example.com' }

    assert_equal('*', response.headers['Access-Control-Allow-Origin'])
    assert_equal('POST, GET, PUT, PATCH, DELETE, OPTIONS',
                 response.headers['Access-Control-Allow-Methods'])
    assert_equal('Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, ' \
                 'X-User-Token, X-User-Email',
               response.headers['Access-Control-Allow-Headers'])
    assert_equal('3600', response.headers['Access-Control-Max-Age'])
  end

  def test_returns_empty_body
    options '/api/v1/registrant/auth/eid', {}

    assert_equal('', response.body)
  end
end
