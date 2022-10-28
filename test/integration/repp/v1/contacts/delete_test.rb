require 'test_helper'

class ReppV1ContactsDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
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

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    delete "/repp/v1/contacts/#{contacts(:invalid_email).code}", headers: @auth_headers
    delete "/repp/v1/contacts/#{contacts(:john).code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end
end
