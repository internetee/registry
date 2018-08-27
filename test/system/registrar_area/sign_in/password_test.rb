require 'test_helper'

class RegistrarAreaPasswordSignInTest < ApplicationSystemTestCase
  setup do
    @user = users(:api_bestnames)
  end

  def test_correct_username_and_password
    login_with_correct_credentials
    assert_text 'Log out'
    assert_current_path registrar_root_path
  end

  def test_after_successful_sign_in_super_user_sees_service_message_list
    @user.update!(roles: [ApiUser::SUPER])
    login_with_correct_credentials
    assert_current_path registrar_root_path
  end

  def test_after_successful_sign_in_billing_user_sees_profile
    @user.update!(roles: [ApiUser::BILLING])
    login_with_correct_credentials
    assert_current_path registrar_profile_path
  end

  def test_wrong_password
    visit new_registrar_user_session_url
    fill_in 'registrar_user_username', with: @user.username
    fill_in 'registrar_user_password', with: 'wrong'
    click_button 'Login'

    assert_text 'No such user'
    assert_current_path new_registrar_user_session_path
  end

  def test_inactive_user
    @user.update!(active: false)
    login_with_correct_credentials

    assert_text 'User is not active'
    assert_current_path new_registrar_user_session_path
  end

  private

  def login_with_correct_credentials
    visit new_registrar_user_session_url
    fill_in 'registrar_user_username', with: @user.username
    fill_in 'registrar_user_password', with: 'testtest'
    click_button 'Login'
  end
end