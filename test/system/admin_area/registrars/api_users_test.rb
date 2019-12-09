require 'application_system_test_case'

class AdminRegistrarsApiUsersSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_creates_new_api_user_with_required_attributes
    username = 'john'
    registrar = registrars(:bestnames)

    visit admin_registrar_path(registrar)
    click_on 'New API user'

    fill_in 'Username', with: username
    fill_in 'Password', with: valid_password
    click_on 'Save'

    assert_text 'Record created'
    assert_text "Username #{username}"
  end

  private

  def valid_password
    'testtest'
  end
end
