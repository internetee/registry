require 'application_system_test_case'

class RegistrarAreaBaseTestTest < ApplicationSystemTestCase
  setup do
    @original_registrar_area_ip_whitelist = Setting.registrar_ip_whitelist_enabled
  end

  teardown do
    Setting.registrar_ip_whitelist_enabled = @original_registrar_area_ip_whitelist
  end

  def test_user_cannot_access_without_ip_address_being_whitelisted
    Setting.registrar_ip_whitelist_enabled = true
    WhiteIp.delete_all

    visit new_registrar_user_session_url

    assert_text 'Access denied from IP 127.0.0.1'
    assert_no_button 'Login'
  end

  def test_user_can_access_when_ip_is_whitelisted
    white_ips(:one).update!(ipv4: '127.0.0.1', interfaces: [WhiteIp::REGISTRAR])
    Setting.registrar_ip_whitelist_enabled = true

    visit new_registrar_user_session_url

    assert_no_text 'Access denied from IP 127.0.0.1'
    assert_button 'Login'
  end

  def test_user_can_access_when_ip_is_not_whitelisted_and_whitelist_is_disabled
    Setting.registrar_ip_whitelist_enabled = false
    WhiteIp.delete_all

    visit new_registrar_user_session_url

    assert_no_text 'Access denied from IP 127.0.0.1'
    assert_button 'Login'
  end
end
