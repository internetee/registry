require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiDomainsTest < ActionDispatch::IntegrationTest
  def setup
    super

    @domain = domains(:hospital)
    @registrant = @domain.registrant
  end

  def teardown
    super
  end

  def test_get_domain_details_by_uuid
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37'
    assert_equal(200, response.status)

    domain = JSON.parse(response.body, symbolize_names: true)
    assert_equal('hospital.test', domain[:name])
  end

  def test_get_non_existent_domain_details_by_uuid
    get '/api/v1/registrant/domains/random-uuid'
    assert_equal(404, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({errors: ['Domain not found']}, response_json)
  end

  def test_root_returns_domain_list
    get '/api/v1/registrant/domains', {}, @auth_headers
    assert_equal(200, response.status)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/domains', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: ['Not authorized'] }, json_body)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
