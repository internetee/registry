require 'test_helper'

class ReppV1DomainsNameserversTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_can_add_new_nameserver
    payload = {
      nameservers: [
        { hostname: "ns1.domeener.ee",
          ipv4: ["192.168.1.1"],
          ipv6: ["FE80::AEDE:48FF:FE00:1122"]}
      ]
    }

    post "/repp/v1/domains/#{@domain.name}/nameservers", params: payload, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal payload[:nameservers][0][:hostname], @domain.nameservers.last.hostname
    assert_equal payload[:nameservers][0][:ipv4], @domain.nameservers.last.ipv4
    assert_equal payload[:nameservers][0][:ipv6], @domain.nameservers.last.ipv6
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    get "/repp/v1/domains/#{@domain.name}/nameservers", headers: @auth_headers
    get "/repp/v1/domains/#{@domain.name}/nameservers", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_can_remove_existing_nameserver
    payload = {
      nameservers: [
        { hostname: "ns1.domeener.ee",
          ipv4: ["192.168.1.1"],
          ipv6: ["FE80::AEDE:48FF:FE00:1122"]}
      ]
    }

    post "/repp/v1/domains/#{@domain.name}/nameservers", params: payload, headers: @auth_headers
    assert_response :ok

    @domain.reload
    assert @domain.nameservers.where(hostname: payload[:nameservers][0][:hostname]).any?

    delete "/repp/v1/domains/#{@domain.name}/nameservers/#{payload[:nameservers][0][:hostname]}",
           params: payload, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

   @domain.reload
   refute @domain.nameservers.where(hostname: payload[:nameservers][0][:hostname]).any?
  end

  def test_can_not_add_duplicate_nameserver
    payload = {
      nameservers: [
        { hostname: @domain.nameservers.last.hostname,
          ipv4: @domain.nameservers.last.ipv4,
          ipv6: @domain.nameservers.last.ipv6 }
      ]
    }

    post "/repp/v1/domains/#{@domain.name}/nameservers", params: payload, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2302, json[:code]
    assert_equal 'Nameserver already exists on this domain [hostname]', json[:message]
  end

  def test_returns_errors_when_removing_unknown_nameserver
    delete "/repp/v1/domains/#{@domain.name}/nameservers/ns.nonexistant.test", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_returns_error_when_ns_count_too_low
    delete "/repp/v1/domains/#{@domain.name}/nameservers/#{@domain.nameservers.last.hostname}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2308, json[:code]
    assert_equal 'Data management policy violation; Nameserver count must be between 2-11 for active ' \
                 'domains [nameservers]', json[:message]
  end

  def test_validates_dns_when_adding_nameserver
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    # Mock successful DNS validation
    DNSValidator.stub :validate, { errors: [] } do
      payload = {
        nameservers: [
          { hostname: "ns3.example.com",
            ipv4: ["192.168.1.1"],
            ipv6: ["FE80::AEDE:48FF:FE00:1122"]}
        ]
      }

      post "/repp/v1/domains/#{@domain.name}/nameservers", params: payload, headers: @auth_headers
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]
      
      @domain.reload
      assert @domain.nameservers.where(hostname: 'ns3.example.com').any?
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end

  def test_fails_to_add_nameserver_with_invalid_dns
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    # Mock DNS validation failure
    DNSValidator.stub :validate, { errors: ['Nameserver ns3.example.com is not authoritative for domain'] } do
      payload = {
        nameservers: [
          { hostname: "ns3.example.com",
            ipv4: ["192.168.1.1"],
            ipv6: ["FE80::AEDE:48FF:FE00:1122"]}
        ]
      }

      post "/repp/v1/domains/#{@domain.name}/nameservers", params: payload, headers: @auth_headers
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :bad_request
      assert_equal 2306, json[:code]
      assert json[:message].include?('Nameserver ns3.example.com is not authoritative')
      
      @domain.reload
      refute @domain.nameservers.where(hostname: 'ns3.example.com').any?
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end
end
