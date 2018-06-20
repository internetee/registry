require 'test_helper'

class AdminAreaProtectedAreaTest < ActionDispatch::IntegrationTest
  def test_unauthenticated_user_is_asked_to_authenticate_when_navigating_to_protected_area
    visit admin_domains_url
    assert_text 'You need to sign in before continuing'
    assert_current_path new_admin_user_session_path
  end

  def test_authenticated_user_can_access_protected_area
    sign_in users(:admin)
    visit admin_domains_url
    assert_current_path admin_domains_path
  end

  def test_authenticated_user_is_not_asked_to_authenticate_again
    sign_in users(:admin)
    visit new_admin_user_session_url
    assert_text 'You are already signed in'
    assert_current_path admin_root_path
  end
end