require 'test_helper'

class RegistrarAreaPasswordSignInTest < ApplicationSystemTestCase
  def setup
    @user = users(:api_bestnames)
  end

  def test_correct_username_and_password
    visit new_registrar_user_session_url
    fill_in 'depp_user_tag', with: @user.username
    fill_in 'depp_user_password', with: 'testtest'
    click_button 'Login'

    assert_text 'Log out'
    assert_current_path registrar_poll_path
  end

  def test_wrong_password
    visit new_registrar_user_session_url
    fill_in 'depp_user_tag', with: @user.username
    fill_in 'depp_user_password', with: 'wrong'
    click_button 'Login'

    assert_text 'No such user'
    assert_current_path new_registrar_user_session_path
  end

  def test_inactive_user
    @user.update!(active: false)

    visit new_registrar_user_session_url
    fill_in 'depp_user_tag', with: @user.username
    fill_in 'depp_user_password', with: 'testtest'
    click_button 'Login'

    assert_text 'User is not active'
    assert_current_path new_registrar_user_session_path
  end
end