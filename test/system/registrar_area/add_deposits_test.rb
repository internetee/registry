require 'application_system_test_case'

class AddDepositsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
  end
end
