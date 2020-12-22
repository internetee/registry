require 'test_helper'

class ReppV1RegistrarNameserversTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_updates_nameserver_values
    nameserver = nameservers(:shop_ns1)
    payload = {
      "data": {
        "id": nameserver.hostname,
        "type": "nameserver",
        "attributes": {
          "hostname": "#{nameserver.hostname}.test",
          "ipv4": ["1.1.1.1"]
        }
      }
    }

    put '/repp/v1/registrar/nameservers', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal({ hostname: "#{nameserver.hostname}.test", ipv4: ["1.1.1.1"] }, json[:data][:attributes])
    assert_equal({ hostname: "#{nameserver.hostname}.test", ipv4: ["1.1.1.1"] }, json[:data][:attributes])
    assert json[:data][:affected_domains].include? 'airport.test'
    assert json[:data][:affected_domains].include? 'shop.test'
  end

  def test_nameserver_with_hostname_must_exist
    payload = {
      "data": {
        "id": 'ns.nonexistant.test',
        "type": "nameserver",
        "attributes": {
          "hostname": "ns1.dn.test",
          "ipv4": ["1.1.1.1"]
        }
      }
    }

    put '/repp/v1/registrar/nameservers', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_ip_must_be_in_correct_format
    nameserver = nameservers(:shop_ns1)
    payload = {
      "data": {
        "id": nameserver.hostname,
        "type": "nameserver",
        "attributes": {
          "hostname": "#{nameserver.hostname}.test",
          "ipv6": ["1.1.1.1"]
        }
      }
    }

    put '/repp/v1/registrar/nameservers', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2005, json[:code]
    assert_equal 'IPv6 is invalid [ipv6]', json[:message]
  end
end
