require 'test_helper'

class ReppV1BaseTest < ActionDispatch::IntegrationTest
  def setup
    @registrant = users(:api_bestnames)
    token = Base64.encode64("#{@registrant.username}:#{@registrant.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_unauthorized_user_has_no_access
    get repp_v1_contacts_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'Invalid authorization information', response_json[:message]
  end

  def test_authenticates_valid_user
    get repp_v1_contacts_path, headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
  end
end
