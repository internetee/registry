$VERBOSE=nil
require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiCompaniesTest < ApplicationIntegrationTest
  def setup
    super

    @contact = contacts(:john)
    @user = users(:registrant)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_accepts_limit_and_offset_parameters
    contacts(:william).update!(ident: '1234', ident_type: 'priv', ident_country_code: 'US')

    get '/api/v1/registrant/companies', params: { 'limit' => 1, 'offset' => 0 },
        headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(200, response.status)
    assert_equal(1, response_json.values.flatten.count)

    get '/api/v1/registrant/companies', headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(@user.companies.size, response_json.count)
  end

  def test_format
    contacts(:william).update!(ident: '1234', ident_type: 'priv', ident_country_code: 'US')
    get '/api/v1/registrant/companies', headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(1, response_json.count)
    assert response_json.is_a?(Hash)
    assert_equal(:companies, response_json.keys.first)
  end

  def test_returns_empty_companies_when_company_register_api_disabled
    Setting.company_register_api_enabled = 'false'

    get '/api/v1/registrant/companies', headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal(200, response.status)
    assert_equal([], response_json[:companies])
  ensure
    Setting.company_register_api_enabled = 'true'
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
