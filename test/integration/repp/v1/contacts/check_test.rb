require 'test_helper'

class ReppV1ContactsCheckTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_code_based_check_returns_true_for_available_contact
    get '/repp/v1/contacts/check/nonexistant:code', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'nonexistant:code', json[:data][:contact][:id]
    assert_equal true, json[:data][:contact][:available]
  end

  def test_code_based_check_returns_true_for_available_contact
    contact = contacts(:jack)
    get "/repp/v1/contacts/check/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal contact.code, json[:data][:contact][:id]
    assert_equal false, json[:data][:contact][:available]
  end
end
