require 'test_helper'
require 'application_system_test_case'

class AdminAreaAdminUsersIntegrationTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include ActionView::Helpers::NumberHelper

    setup do
        @original_default_language = Setting.default_language
        sign_in users(:admin)
    end

    # "/admin/admin_users"
    def test_create_new_admin_user
        visit admin_admin_users_path
        click_on 'New admin user'

        fill_in 'Username', with: 'test_user_name'
        fill_in 'Password', with: 'test_password'
        fill_in 'Password confirmation', with: 'test_password'
        fill_in 'Identity code', with: '38903110313'
        fill_in 'Email', with: 'oleg@tester.ee'

        select 'Estonia', from: 'admin_user_country_code', match: :first
        select 'User', from: 'admin_user_roles_', match: :first

        click_on 'Save'
        assert_text 'Record created'
    end

    # "/admin/admin_users"
    def test_create_with_invalid_data_new_admin_user
        visit admin_admin_users_path
        click_on 'New admin user'

        fill_in 'Username', with: 'test_user_name'
        fill_in 'Password', with: 'test_password'
        fill_in 'Password confirmation', with: 'test_password2'
        fill_in 'Identity code', with: '38903110313'
        fill_in 'Email', with: 'oleg@tester.ee'

        select 'Estonia', from: 'admin_user_country_code', match: :first
        select 'User', from: 'admin_user_roles_', match: :first

        click_on 'Save'
        assert_text 'Failed to create record'
    end

    def test_edit_successfully_exist_record
        visit admin_admin_users_path
        click_on 'New admin user'

        fill_in 'Username', with: 'test_user_name'
        fill_in 'Password', with: 'test_password'
        fill_in 'Password confirmation', with: 'test_password'
        fill_in 'Identity code', with: '38903110313'
        fill_in 'Email', with: 'oleg@tester.ee'

        select 'Estonia', from: 'admin_user_country_code', match: :first
        select 'User', from: 'admin_user_roles_', match: :first

        click_on 'Save'
        assert_text 'Record created'

        visit admin_admin_users_path
        click_on 'test_user_name'

        assert_text 'General'
        click_on 'Edit'

        fill_in 'Password', with: 'test_password'
        fill_in 'Password confirmation', with: 'test_password'

        click_on 'Save'
        assert_text 'Record updated'

    end
end