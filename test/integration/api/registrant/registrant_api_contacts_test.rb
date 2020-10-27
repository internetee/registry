require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiContactsTest < ApplicationIntegrationTest
  def setup
    super

    @contact = contacts(:john)
    @user = users(:registrant)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_root_accepts_limit_and_offset_parameters
    contacts(:william).update!(ident: '1234', ident_type: 'priv', ident_country_code: 'US')
    assert_equal 4, @user.contacts(representable: false).size

    get '/api/v1/registrant/contacts', params: { 'limit' => 1, 'offset' => 0 },
        headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(200, response.status)
    assert_equal(1, response_json.count)

    get '/api/v1/registrant/contacts', headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(@user.contacts(representable: false).size, response_json.count)
  end

  def test_get_contact_details_by_uuid
    get api_v1_registrant_contact_path(@contact.uuid), headers: @auth_headers

    assert_response :ok
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal 'john@inbox.test', response_json[:email]
  end

  def test_root_does_not_accept_limit_higher_than_200
    get '/api/v1/registrant/contacts', params: { 'limit' => 400, 'offset' => 0 },
        headers: @auth_headers
    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ limit: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_does_not_accept_offset_lower_than_0
    get '/api/v1/registrant/contacts', params: { 'limit' => 200, 'offset' => "-10" },
        headers: @auth_headers
    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ offset: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/contacts'
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
