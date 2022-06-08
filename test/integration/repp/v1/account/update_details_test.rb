require 'test_helper'

class ReppV1AccountUpdateDetailsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_updates_details
    request_body =  {
      account: {
        billing_email: 'donaldtrump@yandex.ru',
        iban: 'GB331111111111111111',
      },
    }

    put '/repp/v1/account', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Your account has been updated', json[:message]

    assert_equal(request_body[:account][:billing_email], @user.registrar.billing_email)
    assert_equal(request_body[:account][:iban], @user.registrar.iban)
  end
end