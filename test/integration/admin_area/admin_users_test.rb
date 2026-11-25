require 'test_helper'
require 'application_system_test_case'

class AdminAreaAdminUsersIntegrationTest < JavaScriptApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActionView::Helpers::NumberHelper

  setup do
    WebMock.allow_net_connect!
    @original_default_language = Setting.default_language
    sign_in users(:admin)
  end

  def test_create_new_admin_user
    create_admin_user(valid: true)
  end

  def test_create_with_invalid_data_new_admin_user
    create_admin_user(valid: false)
  end

  def test_edit_successfully_exist_record
    create_admin_user(valid: true)

    visit admin_admin_users_path
    assert_selector 'a', text: 'test_user_name'
    click_on 'test_user_name'

    assert_text 'General'
    click_on 'Edit'

    assert_selector 'input[name*="password"]'
    fill_in 'Password', with: 'test_password'
    fill_in 'Password confirmation', with: 'test_password'

    click_on 'Save'
    assert_text 'Record updated'
  end

  def test_edit_exist_record_with_invalid_data
    create_admin_user(valid: true)

    visit admin_admin_users_path
    click_on 'test_user_name'

    assert_text 'General'
    click_on 'Edit'

    fill_in 'Password', with: 'test_password'
    fill_in 'Password confirmation', with: 'test_password2'

    click_on 'Save'
    assert_text 'Failed to update record'
  end

  def test_delete_exist_record
    create_admin_user(valid: true)

    visit admin_admin_users_path
    click_on 'test_user_name'
    assert_text 'General'

    accept_confirm { click_on 'Delete' }

    assert_text 'Record deleted'
  end

  private

  def create_admin_user(valid:)
    visit admin_admin_users_path
    click_on 'New admin user'

    fill_in 'Username', with: 'test_user_name'
    if valid
      fill_in 'Password', with: 'test_password'
      fill_in 'Password confirmation', with: 'test_password'
    else
      fill_in 'Password', with: 'test_password'
      fill_in 'Password confirmation', with: 'test_password2'
    end
    fill_in 'Identity code', with: '38903110313'
    fill_in 'Email', with: 'oleg@tester.ee'

    select 'Estonia', from: 'admin_user_country_code', match: :first

    find('form.form-horizontal .selectize-control .selectize-input').click
    find('.selectize-dropdown .option', match: :first).click

    click_on 'Save'

    if valid
      assert_text 'Record created'
    else
      assert_text 'Failed to create record'
    end
  end
end
