require 'application_system_test_case'

class RegistrarAreaProtectedAreaTest < ApplicationSystemTestCase
  def test_anonymous_user_is_asked_to_authenticate_when_navigating_to_protected_area
    visit registrar_domains_url
    assert_text 'You need to sign in before continuing'
    assert_current_path new_registrar_user_session_path
  end

  def test_authenticated_user_can_access_protected_area
    sign_in users(:api_bestnames)
    visit registrar_domains_url

    assert_no_text 'You need to sign in before continuing'
    assert_current_path registrar_domains_path
  end

  def test_authenticated_user_is_not_asked_to_authenticate_again
    sign_in users(:api_bestnames)
    visit new_registrar_user_session_url

    assert_text 'You are already signed in'
    assert_current_path registrar_root_path
  end
end