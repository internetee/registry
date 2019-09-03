require 'application_system_test_case'

class RegistrarAreaSignOutTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
  end

  def test_logout
    visit registrar_root_url
    click_on 'Log out'

    assert_text 'Signed out successfully'
    assert_current_path new_registrar_user_session_path
  end
end