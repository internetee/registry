require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantAPIDomainsTest < ApplicationSystemTestCase
  def setup
    super

    @user = users(:registrant)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_root_returns_domain_list
    get '/api/v1/registrant/domains', {}, @auth_headers
    assert_equal(200, response.status)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/domains', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({error: 'Not authorized'}, json_body)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
