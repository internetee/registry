require 'test_helper'

class ContactsTest < ApplicationIntegrationTest
  def setup
    super

		@contact = contacts(:john)
  end

	def test_return_code_error_if_valid_domain_name
		get "/api/v1/accreditation_center/contacts/?id=Alyosha"
		json = JSON.parse(response.body, symbolize_names: true)

		assert_equal json[:errors], "Contact not found"
	end
end