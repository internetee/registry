require 'test_helper'

class RegistrationCodeTest < ApplicationIntegrationTest
  def setup
    super

    # @contact = contacts(:john)
  end

  def test_return_code_that_all_ok
    get '/api/v1/business_registry/registration_code/common.ee'
    json = JSON.parse(response.body, symbolize_names: true)

    puts(json)
    # assert_equal json[:errors], 'Contact not found'
  end
end
