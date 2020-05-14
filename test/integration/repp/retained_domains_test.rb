require 'test_helper'

class ReppV1RetainedDomainsTest < ActionDispatch::IntegrationTest
  # Uses magical fixtures, will fail once fixtures inside are changed:
  # test/fixtures/blocked_domains.yml
  # test/fixtures/reserved_domains.yml

  def test_get_index
    get repp_v1_retained_domains_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert response_json[:count] == 3

    expected_objects = [{ name: 'blocked.test',
                          status: 'blocked',
                          punycode_name: 'blocked.test' },
                        { name: 'blockedäöüõ.test',
                          status: 'blocked',
                          punycode_name: 'xn--blocked-cxa7mj0e.test' },
                        { name: 'reserved.test',
                          status: 'reserved',
                          punycode_name: 'reserved.test' }]

    assert_equal response_json[:domains], expected_objects
  end

  def test_cors_preflight
    process :options, repp_v1_retained_domains_path, headers: { 'Origin' => 'https://example.com' }

    assert_equal('https://example.com', response.headers['Access-Control-Allow-Origin'])
    assert_equal('POST, GET, PUT, PATCH, DELETE, OPTIONS',
                 response.headers['Access-Control-Allow-Methods'])
    assert_equal('Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, ' \
                 'X-User-Token, X-User-Email',
               response.headers['Access-Control-Allow-Headers'])
    assert_equal('3600', response.headers['Access-Control-Max-Age'])
    assert_equal('', response.body)
  end
end
