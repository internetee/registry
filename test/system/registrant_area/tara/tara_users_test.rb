require 'application_system_test_case'

class RegistrantAreaTaraUsersTest < ApplicationSystemTestCase
  def setup
    super

    OmniAuth.config.test_mode = true
    @registrant = users(:registrant)

    @existing_user_hash = {
        'provider' => 'rant_tara',
        'uid' => "US1234",
        'info': { 'first_name': 'Registrant', 'last_name': 'User' }
    }

    @new_user_hash = {
        'provider' => 'rant_tara',
        'uid' => 'EE51007050604',
        'info': { 'first_name': 'New Registrant', 'last_name': 'User'}
    }
  end

  def teardown
    super

    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth['rant_tara'] = nil
  end

  def test_existing_user_gets_signed_in
    OmniAuth.config.mock_auth[:rant_tara] = OmniAuth::AuthHash.new(@existing_user_hash)

    visit new_registrant_user_session_path
    click_link('Sign in')

    assert_text('Signed in successfully')
  end

  def test_new_user_is_created_and_signed_in
    OmniAuth.config.mock_auth[:rant_tara] = OmniAuth::AuthHash.new(@new_user_hash)

    assert_difference 'RegistrantUser.count' do
      visit new_registrant_user_session_path
      click_link('Sign in')

      assert_equal 'New Registrant User', RegistrantUser.last.username
      assert_equal 'EE-51007050604', RegistrantUser.last.registrant_ident
      assert_text('Signed in successfully')
    end
  end
end
