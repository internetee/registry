require 'test_helper'

class AdminAreaSignInTest < ApplicationSystemTestCase
  def setup
    @user = users(:admin)
  end

  def test_correct_username_and_password
    visit new_admin_user_session_url
    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'testtest'
    click_button 'Sign in'

    assert_text 'Signed in successfully'
    assert_current_path admin_domains_path
  end

  def test_wrong_password
    visit new_admin_user_session_url
    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'wrong'
    click_button 'Sign in'

    assert_text 'Invalid Username or password'
    assert_current_path new_admin_user_session_path
  end

  def test_retry_with_correct_username_and_password
    visit new_admin_user_session_url
    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'wrong'
    click_button 'Sign in'

    assert_text 'Invalid Username or password'
    assert_current_path new_admin_user_session_path

    fill_in 'admin_user_username', with: @user.username
    fill_in 'admin_user_password', with: 'testtest'
    click_button 'Sign in'

    assert_text 'Signed in successfully'
    assert_current_path admin_domains_path
  end
end