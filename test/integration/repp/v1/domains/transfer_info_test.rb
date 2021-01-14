require 'test_helper'

class ReppV1DomainsTransferInfoTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"
    @domain = domains(:shop)
    @auth_headers = { 'Authorization' => token }
  end

  def test_can_query_domain_info
    headers = @auth_headers
    headers['Auth-Code'] = @domain.transfer_code

    get "/repp/v1/domains/#{@domain.name}/transfer_info", headers: headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @domain.name, json[:data][:domain]
    assert json[:data][:registrant].present?
    assert json[:data][:admin_contacts].present?
    assert json[:data][:tech_contacts].present?
  end

  def test_respects_domain_authorization_code
    headers = @auth_headers
    headers['Auth-Code'] = 'jhfgifhdg'

    get "/repp/v1/domains/#{@domain.name}/transfer_info", headers: headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2202, json[:code]
    assert_equal 'Authorization error', json[:message]
    assert_empty json[:data]
  end

  def test_processes_puny_domains
    @domain.update(name_puny: 'xn--prototp-s2aa.ee')

    headers = @auth_headers
    headers['Auth-Code'] = @domain.transfer_code

    get "/repp/v1/domains/xn--prototp-s2aa.ee/transfer_info", headers: headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
  end
end
