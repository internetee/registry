require 'test_helper'

class DomainsTest < ApplicationIntegrationTest
  def setup
    super

		@user = users(:api_bestnames)
		@header = { 'Authorization' => "Basic #{generate_base64}" }
  end

	def test_should_return_cancelled_invoices
		date_now = Time.now

		get "/api/v1/accreditation_center/invoice_status", headers: @header
		json = JSON.parse(response.body, symbolize_names: true)

		assert_equal json[:invoices].count, 0

		invoice = @user.registrar.invoices.last
		invoice.update(cancelled_at: date_now)

		get "/api/v1/accreditation_center/invoice_status", headers: @header
		json = JSON.parse(response.body, symbolize_names: true)

		assert_equal json[:invoices].count, 1
	end

	private

	def generate_base64
    Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
  end
end