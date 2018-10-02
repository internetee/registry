require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiDomainsTest < ApplicationIntegrationTest
  def setup
    super

    @original_registry_time = Setting.days_to_keep_business_registry_cache
    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')

    @domain = domains(:hospital)
    @registrant = @domain.registrant
    @user = users(:registrant)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def teardown
    super

    Setting.days_to_keep_business_registry_cache = @original_registry_time
    travel_back
  end

  def test_get_domain_details_by_uuid
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37', {}, @auth_headers
    assert_equal(200, response.status)

    domain = JSON.parse(response.body, symbolize_names: true)

    assert_equal('hospital.test', domain[:name])
    assert_equal('5edda1a5-3548-41ee-8b65-6d60daf85a37', domain[:id])
    assert_equal('Good Names', domain[:registrar])
    assert_equal([], domain[:nameservers])
    assert(domain.has_key?(:locked_by_registrant_at))
  end

  def test_get_non_existent_domain_details_by_uuid
    get '/api/v1/registrant/domains/random-uuid', {}, @auth_headers
    assert_equal(404, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [base: ['Domain not found']] }, response_json)
  end

  def test_root_returns_domain_list
    get '/api/v1/registrant/domains', {}, @auth_headers
    assert_equal(200, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    array_of_domain_names = response_json.map { |x| x[:name] }
    assert(array_of_domain_names.include?('hospital.test'))

    array_of_domain_registrars = response_json.map { |x| x[:registrar] }
    assert(array_of_domain_registrars.include?('Good Names'))
  end

  def test_root_accepts_limit_and_offset_parameters
    get '/api/v1/registrant/domains', { 'limit' => 2, 'offset' => 0 }, @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal(200, response.status)
    assert_equal(2, response_json.count)

    get '/api/v1/registrant/domains', {}, @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal(4, response_json.count)
  end

  def test_root_does_not_accept_limit_higher_than_200
    get '/api/v1/registrant/domains', { 'limit' => 400, 'offset' => 0 }, @auth_headers

    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ limit: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_does_not_accept_offset_lower_than_0
    get '/api/v1/registrant/domains', { 'limit' => 200, 'offset' => "-10" }, @auth_headers

    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ offset: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/domains', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  def test_details_returns_401_without_authorization
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
