require 'test_helper'
require 'application_system_test_case'

class AdminAreaAccountActivitiesIntegrationTest < ApplicationSystemTestCase
    # /admin/account_activities
    include Devise::Test::IntegrationHelpers
    include ActionView::Helpers::NumberHelper

    setup do
        sign_in users(:admin)
        @original_default_language = Setting.default_language
    end


    # TESTS
    # TODO

end