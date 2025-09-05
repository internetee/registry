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

  def test_bulk_update_nameservers_with_valid_csv
    csv_file = fixture_file_upload('files/nameserver_change_valid.csv', 'text/csv')
    
    post "/repp/v1/domains/nameservers/bulk", headers: @auth_headers, 
         params: { csv_file: csv_file, new_hostname: 'ns1.newserver.ee' }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal 1, json[:data][:success].length
    assert_equal @domain.name, json[:data][:success][0][:domain_name]
  end

  def test_returns_error_with_invalid_csv_headers_bulk
    csv_file = fixture_file_upload('files/nameserver_change_invalid.csv', 'text/csv')
    
    post "/repp/v1/domains/nameservers/bulk", headers: @auth_headers,
         params: { csv_file: csv_file, new_hostname: 'ns1.newserver.ee' }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 1, json[:data][:failed].length
    assert_equal 'csv_error', json[:data][:failed][0][:type]
    assert_includes json[:data][:failed][0][:message], 'CSV file is empty or missing required header'
  end
end
