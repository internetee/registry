require 'test_helper'

class AuthTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    @header = { 'Authorization' => "Basic #{generate_base64}" }

    # Enable the accreditation endpoints feature for testing
    ENV['allow_accr_endspoints'] = 'true'
  end

  def teardown
    # Clean up environment variable
    ENV.delete('allow_accr_endspoints')
    super
  end

  def test_should_return_successful
    get '/api/v1/accreditation_center/auth', headers: @header

    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal json[:code], 1000
    assert_equal json[:message], 'Command completed successfully'
  end

  def test_should_return_failed
    get '/api/v1/accreditation_center/auth', headers: { 'Authorization' => "Basic LAHSDHDSAFSF#@" }

    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  def test_should_return_forbidden_when_feature_disabled
    # Disable the feature
    ENV['allow_accr_endspoints'] = 'false'

    get '/api/v1/accreditation_center/auth', headers: @header

    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal json[:errors], 'Accreditation Center API is not allowed'
    assert_equal response.status, 403
  end

  private

  def generate_base64
    Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
  end
end
