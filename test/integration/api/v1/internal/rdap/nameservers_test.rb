require 'test_helper'

class ApiV1InternalRdapNameserversTest < ApplicationIntegrationTest
  def setup
    ENV['rdap_internal_api_shared_key'] = 'test-rdap-key'
    ENV['rdap_internal_api_allowed_ips'] = '127.0.0.1,::1'
    @header = { 'Authorization' => 'Basic test-rdap-key' }
  end

  def teardown
    ENV.delete('rdap_internal_api_shared_key')
    ENV.delete('rdap_internal_api_allowed_ips')
    super
  end

  def test_returns_thin_nameserver_shape
    get '/api/v1/internal/rdap/nameservers/ns1.bestnames.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'ns1.bestnames.test', json[:hostname]
    assert_equal 'ns1.bestnames.test', json[:hostname_puny]
  end

  # ns1.bestnames.test is attached to shop, airport AND metro in the fixtures.
  # The endpoint must DISTINCT-collapse to a single object (an Object, not an
  # Array) and never leak glue or a domain list (prevents enumeration).
  def test_distinct_collapses_multi_domain_host_and_hides_glue
    assert_operator Nameserver.where(hostname: 'ns1.bestnames.test').count, :>, 1

    get '/api/v1/internal/rdap/nameservers/ns1.bestnames.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_kind_of Hash, json
    assert_equal %i[hostname hostname_puny].sort, json.keys.sort
    refute json.key?(:ipv4)
    refute json.key?(:ipv6)
    refute json.key?(:domains)
    refute json.key?(:domain_id)
  end

  def test_matches_on_hostname_puny
    get '/api/v1/internal/rdap/nameservers/ns2.bestnames.test', headers: @header
    assert_response :ok
  end

  def test_returns_404_when_not_found
    get '/api/v1/internal/rdap/nameservers/ns9.nope.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 'Nameserver not found', json[:message]
  end

  def test_requires_authentication
    get '/api/v1/internal/rdap/nameservers/ns1.bestnames.test'
    assert_response :unauthorized
  end
end
