require 'rails_helper'

RSpec.feature 'Mobile ID login', db: true do
  given!(:api_user) { create(:api_user, identity_code: 1234) }

  background do
    Setting.registrar_ip_whitelist_enabled = false
    digidoc_client = instance_double(Digidoc::Client, authenticate: OpenStruct.new(user_id_code: 1234), session_code: 1234)
    allow(Digidoc::Client).to receive(:new).and_return(digidoc_client)
  end

  scenario 'login with phone number' do
    visit registrar_login_path
    click_on 'login-with-mobile-id-btn'

    fill_in 'user[phone]', with: '1234'
    click_button 'Login'

    expect(page).to have_text('Confirmation sms was sent to your phone. Verification code is')
  end
end
