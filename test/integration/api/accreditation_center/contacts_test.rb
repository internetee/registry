require 'test_helper'

class ContactsTest < ApplicationIntegrationTest
  def setup
    super

    @contact = contacts(:john)
  end

  def test_return_code_error_if_valid_domain_name
    get '/api/v1/accreditation_center/contacts/?id=Alyosha'
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:errors], 'Contact not found'
  end

  def test_return_code_error_if_sdfsdf
    get "/api/v1/accreditation_center/contacts/?id=#{@contact.code}"
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal json[:contact][:name], 'John'
  end

  def test_parameter_missing_error
    get '/api/v1/accreditation_center/contacts'  # without name parameter
    json = JSON.parse(response.body, symbolize_names: true)
  
    assert_response 404
    assert_equal 'Contact not found', json[:errors]
  end

  def test_record_not_found_error
    get '/api/v1/accreditation_center/contacts/?id=non_existent'
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response 404
    assert_equal 'Contact not found', json[:errors]
  end
end
