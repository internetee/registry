require 'test_helper'

class AdminAreaLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:admin)
  end

  def test_correct_username_and_password
    visit new_admin_user_session_url
    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'testtest'
    click_button 'Log in'

    assert_text 'Log out'
    assert_current_path admin_root_path
  end

  def test_wrong_password
    visit new_admin_user_session_url
    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'wrong'
    click_button 'Log in'

    assert_text 'Authorization error'
    assert_current_path new_admin_user_session_path
  end
end