require 'test_helper'

class ReppV1ContactsDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_deletes_unassociated_contact
    contact = contacts(:invalid_email)
    delete "/repp/v1/contacts/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
  end

  def test_can_not_delete_associated_contact
    contact = contacts(:john)
    delete "/repp/v1/contacts/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2305, json[:code]
    assert_equal 'Object association prohibits operation [domains]', json[:message]
  end

  def test_handles_unknown_contact
    delete "/repp/v1/contacts/definitely:unexistant", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
  end

  def test_can_not_destroy_other_registrar_contact
    contact = contacts(:jack)

    delete "/repp/v1/contacts/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
  end
end
