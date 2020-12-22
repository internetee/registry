require 'test_helper'

class ReppV1DomainsListTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_registrar_domains
    get repp_v1_domains_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.domains.count, json[:data][:total_number_of_records]
    assert_equal @user.registrar.domains.count, json[:data][:domains].length

    assert json[:data][:domains][0].is_a? String
  end

  def test_returns_detailed_registrar_domains
    get repp_v1_domains_path(details: true), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.domains.count, json[:data][:total_number_of_records]
    assert_equal @user.registrar.domains.count, json[:data][:domains].length

    assert json[:data][:domains][0].is_a? Hash
  end

  def test_respects_limit
    get repp_v1_domains_path(details: true, limit: 2), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal 2, json[:data][:domains].length
  end

  def test_respects_offset
    offset = 1
    get repp_v1_domains_path(details: true, offset: offset), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal (@user.registrar.domains.count - offset), json[:data][:domains].length
  end
end
