require 'application_system_test_case'

class AdminApiUsersSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_shows_api_user_list
    visit admin_api_users_path

    api_user = users(:api_bestnames)
    assert_link api_user.username, href: admin_registrar_api_user_path(api_user.registrar, api_user)
  end
end
