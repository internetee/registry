require 'test_helper'

class RegistrantAreaIdCardSignInTest < ApplicationIntegrationTest
  setup do
    allow_business_registry_component_reach_server
  end

  def test_succeeds
    post_via_redirect registrant_id_card_sign_in_path, nil,
                      'SSL_CLIENT_S_DN_CN' => 'DOE,JOHN,1234',
                      'SSL_CLIENT_I_DN_C' => 'US'

    assert_response :ok
    assert_equal registrant_root_path, path
    assert_not_nil controller.current_registrant_user
  end

  def test_fails_when_certificate_is_absent
    post_via_redirect registrant_id_card_sign_in_path, nil, 'SSL_CLIENT_S_DN_CN' => ''

    assert_response :ok
    assert_equal registrant_id_card_sign_in_path, path
    assert_nil controller.current_registrant_user
  end

  private

  def allow_business_registry_component_reach_server
    WebMock.allow_net_connect!
  end
end