require 'test_helper'

class AuthTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    @header = { 'Authorization' => "Basic #{generate_base64}" }
  end

  def test_should_return_successful
    get 'https://registry.test/api/v1/accreditation_center/auth', headers: @header

    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal json[:code], 1000
    assert_equal json[:message], 'Command completed successfully'
  end

  def test_should_return_failed
    get 'https://registry.test/api/v1/accreditation_center/auth', headers: { 'Authorization' => "Basic LAHSDHDSAFSF#@" }

    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  private

  def generate_base64
    Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
  end
end
