require 'test_helper'

class ContactsTest < ApplicationIntegrationTest
  def setup
    super

    @contact = contacts(:john)
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

  def test_return_successful_with_valid_contact
    get "/api/v1/accreditation_center/contacts/?id=#{@contact.code}", headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:contact][:name], 'John'
  end

  def test_return_error_if_contact_not_found
    get '/api/v1/accreditation_center/contacts/?id=Alyosha', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response 404
    assert_equal json[:errors], 'Contact not found'
  end

  def test_return_error_without_authentication
    get '/api/v1/accreditation_center/contacts/?id=test'
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response 401
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  def test_return_forbidden_when_feature_disabled
    # Disable the feature
    ENV['allow_accr_endspoints'] = 'false'

    get "/api/v1/accreditation_center/contacts/?id=#{@contact.code}", headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:errors], 'Accreditation Center API is not allowed'
    assert_equal response.status, 403
  end

  def test_record_not_found_error
    get '/api/v1/accreditation_center/contacts/?id=non_existent', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response 404
    assert_equal 'Contact not found', json[:errors]
  end

  private

  def generate_base64
    Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
  end
end
