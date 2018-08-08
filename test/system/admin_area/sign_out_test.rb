require 'test_helper'

class AdminAreaSignOutTest < ApplicationSystemTestCase
  def setup
    sign_in users(:admin)
  end

  def test_logout
    visit admin_root_url
    click_on 'Sign out'

    assert_text 'Signed out successfully'
    assert_current_path new_admin_user_session_path
  end
end