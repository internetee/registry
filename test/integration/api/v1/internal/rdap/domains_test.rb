require 'test_helper'

class ApiV1InternalRdapDomainsTest < ApplicationIntegrationTest
  def setup
    @domain = domains(:shop)
    ENV['rdap_internal_api_shared_key'] = 'test-rdap-key'
    ENV['rdap_internal_api_allowed_ips'] = '127.0.0.1,::1'
    @header = { 'Authorization' => 'Basic test-rdap-key' }
  end

  def teardown
    ENV.delete('rdap_internal_api_shared_key')
    ENV.delete('rdap_internal_api_allowed_ips')
    super
  end

  def test_returns_domain_by_name
    get '/api/v1/internal/rdap/domains/shop.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'shop.test', json[:name]
    assert_equal @domain.registrant.name, json[:registrant][:name]
    assert_equal 'bestnames', json[:registrar][:code]
    # registrar embedded in the domain keeps email + reg_no (§1.4)
    assert_equal @domain.registrar.email, json[:registrar][:email]
    assert_equal @domain.registrar.reg_no, json[:registrar][:reg_no]
    # admin/tech contacts via STI assocs
    assert_includes json[:admin_contacts].map { |c| c[:name] }, contacts(:jane).name
    assert_includes json[:tech_contacts].map { |c| c[:name] }, contacts(:william).name
    # nameservers carry glue
    hostnames = json[:nameservers].map { |n| n[:hostname] }
    assert_includes hostnames, 'ns1.bestnames.test'
  end

  def test_matches_on_name_puny
    get '/api/v1/internal/rdap/domains/shop.test', headers: @header
    assert_response :ok
  end

  def test_response_never_contains_secrets
    get '/api/v1/internal/rdap/domains/shop.test', headers: @header

    assert_response :ok
    body = response.body
    # the shop domain has transfer_code 65078d5; registrant john has auth_info cacb5b
    refute_includes body, 'transfer_code'
    refute_includes body, 'auth_info'
    refute_includes body, 'registrant_verification_token'
    refute_includes body, @domain.transfer_code
    refute_includes body, @domain.registrant.auth_info
  end

  def test_disclosed_attributes_is_union_of_both_arrays
    contact = @domain.registrant
    contact.update_columns(disclosed_attributes: %w[name email],
                           system_disclosed_attributes: %w[phone email])

    get '/api/v1/internal/rdap/domains/shop.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal %w[name email phone].sort,
                 json[:registrant][:disclosed_attributes].sort
  end

  def test_returns_404_when_domain_not_found
    get '/api/v1/internal/rdap/domains/nonexistent.test', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 'Domain not found', json[:message]
  end

  def test_requires_authentication
    get '/api/v1/internal/rdap/domains/shop.test'
    assert_response :unauthorized
  end

  def test_rejects_wrong_shared_key
    get '/api/v1/internal/rdap/domains/shop.test',
        headers: { 'Authorization' => 'Basic wrong-key' }
    assert_response :unauthorized
  end

  def test_rejects_non_whitelisted_ip
    get '/api/v1/internal/rdap/domains/shop.test',
        headers: @header.merge('REMOTE_ADDR' => '10.10.10.10')
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'IP address 10.10.10.10 is not authorized', json[:message]
  end
end
