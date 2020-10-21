require 'test_helper'

class ReppV1DomainsTransferTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"
    @domain = domains(:hospital)

    @auth_headers = { 'Authorization' => token }
  end

  def test_transfers_domain
    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": @domain.transfer_code }
        ]
      }
    }
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal @domain.name, json[:data][0][:attributes][:domain_name]
    assert_equal 'domain_transfer', json[:data][0][:type]
  end

  def test_does_not_transfer_domain_with_invalid_auth_code
    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": "sdfgsdfg" }
        ]
      }
    }
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert_equal 'Command failed', json[:message]

    assert_equal "#{@domain.name} transfer code is wrong", json[:data][0][:title]
  end
end
