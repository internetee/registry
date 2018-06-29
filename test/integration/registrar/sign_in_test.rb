require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest
  def setup
    super
    WebMock.allow_net_connect!

    @user = users(:api_bestnames)
    @user.identity_code = '1234'
    @user.save
  end

  def test_mobile_id_sign_in_page
    mock_client = Minitest::Mock.new
    mock_client.expect(:authenticate, OpenStruct.new(user_id_code: '1234'),
                       [{ phone: "+3721234",
                         message_to_display: "Authenticating",
                         service_name: "Testimine" }])
    mock_client.expect(:session_code, 1234)

    Digidoc::Client.stub(:new, mock_client) do
      visit registrar_login_path

      click_on 'login-with-mobile-id-btn'

      fill_in 'user[phone]', with: '1234'
      click_button 'Login'

      assert(page.has_text?('Confirmation sms was sent to your phone. Verification code is'))
    end
  end
end
