require 'test_helper'

class RegistrarAreaLogoutTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:api_bestnames)
  end

  def test_logout
    visit registrar_root_url
    click_on 'Log out'

    assert_text 'Signed out successfully'
    assert_current_path new_registrar_user_session_path
  end
end