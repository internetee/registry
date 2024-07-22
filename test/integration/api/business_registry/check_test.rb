require 'test_helper'

class CheckTest < ApplicationIntegrationTest
  fixtures :reserved_domains

  def setup
    super
    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip

    ENV['ALLOWED_ORIGINS'] = 'http://example.com,http://test.com'
  end

  def test_return_list_of_available_organization_domain_names
    get '/api/v1/business_registry/check?organization_name=Company Name AS', headers: { 'Origin' => 'http://example.com', 'REMOTE_ADDR' => @valid_ip }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :success
    assert_equal 'http://example.com', response.headers['Access-Control-Allow-Origin']
    refute_includes json[:variants], 'company-name.test'
    assert_includes json[:variants], 'companyname'
    assert_includes json[:variants], 'company-name'
    assert_includes json[:variants], 'company_name'
    assert_includes json[:variants], "companyname#{Time.current.year}"
    refute_includes json[:variants].join, 'as'
  end

  def test_single_word_company_name
    get '/api/v1/business_registry/check?organization_name=Reserved', headers: { 'Origin' => 'http://test.com', 'REMOTE_ADDR' => @valid_ip }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :success
    assert_equal 'http://test.com', response.headers['Access-Control-Allow-Origin']
    assert_includes json[:variants], 'reserved'
    refute_includes json[:variants], 'reserved.test'
    assert_includes json[:variants], "reserved#{Time.current.year}"
  end

  def test_invalid_organization_name
    get '/api/v1/business_registry/check?organization_name=Invalid!@#Name', headers: { 'Origin' => 'http://example.com', 'REMOTE_ADDR' => @valid_ip }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Invalid organization name', json[:error]
  end

  def test_cors_with_disallowed_origin
    get '/api/v1/business_registry/check?organization_name=Test', headers: { 'Origin' => 'http://malicious.com', 'REMOTE_ADDR' => @valid_ip }
    
    assert_response :unauthorized
    assert_nil response.headers['Access-Control-Allow-Origin']
  end
end
