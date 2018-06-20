require 'test_helper'

class AdminAreaLogoutTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:admin)
  end

  def test_logout
    visit admin_root_url
    click_on 'Log out'

    assert_text 'Signed out successfully'
    assert_current_path new_admin_user_session_path
  end
end