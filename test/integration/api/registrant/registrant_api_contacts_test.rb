require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiContactsTest < ApplicationIntegrationTest
  def setup
    super

    @original_registry_time = Setting.days_to_keep_business_registry_cache
    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')

    @user = users(:registrant)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def teardown
    super

    Setting.days_to_keep_business_registry_cache = @original_registry_time
    travel_back
  end

  def test_root_returns_domain_list
    get '/api/v1/registrant/contacts', {}, @auth_headers
    assert_equal(200, response.status)

    json_body = JSON.parse(response.body, symbolize_names: true)
    assert_equal(5, json_body.count)
    array_of_contact_codes = json_body.map { |x| x[:code] }
    assert(array_of_contact_codes.include?('william-001'))
    assert(array_of_contact_codes.include?('jane-001'))
  end

  def test_root_accepts_limit_and_offset_parameters
    get '/api/v1/registrant/contacts', { 'limit' => 1, 'offset' => 0 }, @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(200, response.status)
    assert_equal(1, response_json.count)

    get '/api/v1/registrant/contacts', {}, @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(5, response_json.count)
  end

  def test_get_contact_details_by_uuid
    get '/api/v1/registrant/contacts/0aa54704-d6f7-4ca9-b8ca-2827d9a4e4eb', {}, @auth_headers
    assert_equal(200, response.status)

    contact = JSON.parse(response.body, symbolize_names: true)
    assert_equal('william@inbox.test', contact[:email])
  end

  def test_get_contact_details_by_uuid_returns_404_for_non_existent_contact
    get '/api/v1/registrant/contacts/nonexistent-uuid', {}, @auth_headers
    assert_equal(404, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ base: ['Contact not found'] }] }, response_json)
  end

  def test_root_does_not_accept_limit_higher_than_200
    get '/api/v1/registrant/contacts', { 'limit' => 400, 'offset' => 0 }, @auth_headers
    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ limit: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_does_not_accept_offset_lower_than_0
    get '/api/v1/registrant/contacts', { 'limit' => 200, 'offset' => "-10" }, @auth_headers
    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ offset: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/contacts', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  def test_details_returns_401_without_authorization
    get '/api/v1/registrant/contacts/c0a191d5-3793-4f0b-8f85-491612d0293e', {}, {}
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  def test_details_returns_404_for_non_existent_contact
    get '/api/v1/registrant/contacts/some-random-uuid', {}, @auth_headers
    assert_equal(404, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Contact not found']] }, json_body)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
