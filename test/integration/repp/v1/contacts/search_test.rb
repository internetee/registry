require 'test_helper'

class ReppV1ContactsSearchTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_searches_all_contacts_by_id
    contact = contacts(:john)
    get "/repp/v1/contacts/search/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert json[:data].is_a? Array
    assert_equal json[:data][0][:value], contact.code
    assert_equal json[:data][0][:label], "#{contact.code} #{contact.name}"
    assert_equal json[:data][0][:selected], true
  end

  def test_searches_all_contacts_by_query
    get '/repp/v1/contacts/search', headers: @auth_headers, params: { query: 'j' }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert json[:data].is_a? Array
    assert_equal json[:data].length, 2
    assert_equal json[:data][0][:selected], false
    assert_equal json[:data][1][:selected], false
  end

  def test_searches_all_contacts_by_wrong_query
    get '/repp/v1/contacts/search', headers: @auth_headers, params: { query: '000' }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert json[:data].is_a? Array
    assert_equal json[:data].length, 0
  end
end