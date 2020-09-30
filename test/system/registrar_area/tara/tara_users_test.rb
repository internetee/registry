require 'application_system_test_case'

class TaraUsersTest < ApplicationSystemTestCase
  def setup
    super

    OmniAuth.config.test_mode = true
    @user = users(:api_bestnames)

    @existing_user_hash = {
        'provider' => 'tara',
        'uid' => "EE" + @user.identity_code
    }

    @new_user_hash = {
        'provider' => 'tara',
        'uid' => 'EE51007050604'
    }
  end

  def teardown
    super

    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth['tara'] = nil
  end

  def test_existing_user_gets_signed_in
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@existing_user_hash)

    visit new_registrar_user_session_path
    click_link('Sign in')

    assert_text('Signed in successfully')
  end

  def test_nonexisting_user_gets_error_message
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@new_user_hash)

    visit new_registrar_user_session_path
    click_link('Sign in')

    assert_text('No such user')
  end
end
