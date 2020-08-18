require 'test_helper'

class RegistrarAreaIdCardSignInTest < ApplicationIntegrationTest
  setup do
    @user = users(:api_bestnames)
    @original_registrar_area_ip_whitelist = Setting.registrar_ip_whitelist_enabled
  end

  teardown do
    Setting.registrar_ip_whitelist_enabled = @original_registrar_area_ip_whitelist
  end

  def test_signs_in_a_user_when_id_card_owner_is_found
    assert_equal '1234', @user.identity_code

    post registrar_id_card_sign_in_path, headers: { 'SSL_CLIENT_S_DN_CN' => 'DOE,JOHN,1234' }
    follow_redirect!

    assert_response :ok
    assert_equal registrar_root_path, path
    assert_not_nil controller.current_registrar_user
  end

  def test_does_not_sign_in_a_user_when_id_card_owner_is_not_found
    post registrar_id_card_sign_in_path,
         headers: { 'SSL_CLIENT_S_DN_CN' => 'DOE,JOHN,unacceptable-personal-code' }

    assert_nil controller.current_registrar_user
    assert_equal registrar_id_card_sign_in_path, path
    assert_includes response.body, 'Failed to Login'
  end

  def test_does_not_sign_in_a_user_when_id_card_owner_is_found_but_ip_is_not_allowed
    allow_access_to_sign_in_page
    assert_equal '127.0.0.1', white_ips(:one).ipv4
    assert_equal '1234', @user.identity_code

    Setting.registrar_ip_whitelist_enabled = true

    post registrar_id_card_sign_in_path, headers: { 'SSL_CLIENT_S_DN_CN' => 'DOE,JOHN,1234',
                                                    'REMOTE_ADDR' => '127.0.0.2' }

    assert_equal registrar_id_card_sign_in_path, path
    assert_equal 'Access denied from IP 127.0.0.2', response.body

    get registrar_root_path
    assert_redirected_to new_registrar_user_session_path
  end

  def test_does_not_sign_in_a_user_when_certificate_is_absent
    post registrar_id_card_sign_in_path, headers: { 'SSL_CLIENT_S_DN_CN' => '' }

    assert_nil controller.current_registrar_user
    assert_equal registrar_id_card_sign_in_path, path
  end

  private

  def allow_access_to_sign_in_page
    another_registrar_white_ip = white_ips(:one).dup
    another_registrar_white_ip.ipv4 = '127.0.0.2'
    another_registrar_white_ip.registrar = registrars(:goodnames)
    another_registrar_white_ip.save!
  end
end