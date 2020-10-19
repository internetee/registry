require 'test_helper'

class ReppV1ContactsShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_error_when_not_found
    get repp_v1_contact_path(id: 'definitelynotexistant'), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_shows_existing_contact
    contact = @user.registrar.contacts.first

    get repp_v1_contact_path(id: contact.code), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal contact.code, json[:data][:code]
  end

  def test_can_not_access_out_of_scope_contacts
    # Contact of registrar goodnames, we're using bestnames API credentials
    contact = contacts(:jack)

    get repp_v1_contact_path(id: contact.code), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end
end
