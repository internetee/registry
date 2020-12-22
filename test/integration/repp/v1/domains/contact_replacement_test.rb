require 'test_helper'

class ReppV1DomainsContactReplacementTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_replaces_tech_contact_with_new_one
    replaceable_contact = contacts(:william)
    replacing_contact = contacts(:jane)

    payload = {
      "current_contact_id": replaceable_contact.code,
      "new_contact_id": replacing_contact.code
    }

    patch '/repp/v1/domains/contacts', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert json[:data][:affected_domains].include? 'airport.test'
    assert json[:data][:affected_domains].include? 'shop.test'

    assert_empty json[:data][:skipped_domains]
  end

  def test_tech_contact_id_must_differ
    replaceable_contact = contacts(:william)
    replacing_contact = contacts(:william)

    payload = {
      "current_contact_id": replaceable_contact.code,
      "new_contact_id": replacing_contact.code
    }

    patch '/repp/v1/domains/contacts', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert_equal 'New contact must be different from current', json[:message]
  end

  def test_contact_codes_must_be_valid
    payload = {
      "current_contact_id": 'dfgsdfg',
      "new_contact_id": 'vvv'
    }

    patch '/repp/v1/domains/contacts', headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

end
