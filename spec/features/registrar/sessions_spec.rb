require 'rails_helper'

RSpec.feature 'Sessions', db: true do
  context 'with invalid ip' do
    it 'should not see login page' do
      Setting.registrar_ip_whitelist_enabled = true
      WhiteIp.destroy_all
      visit registrar_login_path
      page.should have_text('Access denied')
    end

    it 'should see login page when whitelist disabled' do
      Setting.registrar_ip_whitelist_enabled = false
      WhiteIp.destroy_all
      visit registrar_login_path
      page.should_not have_text('Access denied')
      Setting.registrar_ip_whitelist_enabled = true
    end

    it 'should see Login' do
      @fixed_registrar = Fabricate(:registrar, name: 'fixed registrar', code: 'FIXED')
      @fixed_registrar.white_ips = [Fabricate(:white_ip_registrar)]
      visit registrar_login_path
      page.should have_text('Login')
    end

    it 'should not get in with invalid ip' do
      Fabricate(:registrar, white_ips: [Fabricate(:white_ip), Fabricate(:white_ip_registrar)])
      @api_user_invalid_ip = Fabricate(
          :api_user, identity_code: '37810013294', registrar: Fabricate(:registrar, white_ips: [])
      )
      visit registrar_login_path
      fill_in 'depp_user_tag', with: @api_user_invalid_ip.username
      fill_in 'depp_user_password', with: @api_user_invalid_ip.password
      click_button 'Login'
      page.should have_text('IP is not whitelisted')
    end
  end

  context 'as unknown user' do
    before :example do
      Fabricate(:api_user)
    end

    it 'should not get in' do
      client = instance_double("Digidoc::Client")
      allow(client).to receive(:authenticate).and_return(
          OpenStruct.new(
              user_id_code: '123'
          )
      )

      allow(Digidoc::Client).to receive(:new) { client }

      visit registrar_login_path
      page.should have_css('a[href="/registrar/login/mid"]')

      page.find('a[href="/registrar/login/mid"]').click

      fill_in 'user_phone', with: '00007'
      click_button 'Login'
      page.should have_text('No such user')
    end
  end

  context 'as known api user' do
    before :example do
      Fabricate(:api_user)
    end

    it 'should not get in when external service fails' do
      client = instance_double("Digidoc::Client")
      allow(client).to receive(:authenticate).and_return(
          OpenStruct.new(
              faultcode: 'Fault',
              detail: OpenStruct.new(
                  message: 'Something is wrong'
              )
          )
      )

      allow(Digidoc::Client).to receive(:new) { client }

      visit registrar_login_path
      page.should have_css('a[href="/registrar/login/mid"]')

      page.find('a[href="/registrar/login/mid"]').click

      fill_in 'user_phone', with: '00007'
      click_button 'Login'
      page.should have_text('Something is wrong')
    end

    it 'should not get in when there is a sim error', js: true do
      client = instance_double("Digidoc::Client", session_code: '123')

      allow(client).to receive('session_code=')

      allow(client).to receive(:authenticate).and_return(
          OpenStruct.new(
              user_id_code: '14212128025'
          )
      )

      allow(client).to receive('authentication_status').and_return(
          OpenStruct.new(status: 'SIM_ERROR')
      )

      allow(Digidoc::Client).to receive(:new) { client }

      visit registrar_login_path
      page.should have_css('a[href="/registrar/login/mid"]')

      page.find('a[href="/registrar/login/mid"]').click

      fill_in 'user_phone', with: '00007'
      click_button 'Login'

      page.should have_text('Confirmation sms was sent to your phone. Verification code is')
      page.should have_text('SIM application error')
    end

    it 'should Login successfully', js: true do
      client = instance_double("Digidoc::Client", session_code: '123')

      allow(client).to receive('session_code=')

      allow(client).to receive(:authenticate).and_return(
          OpenStruct.new(
              user_id_code: '14212128025'
          )
      )

      allow(client).to receive('authentication_status').and_return(
          OpenStruct.new(status: 'USER_AUTHENTICATED')
      )

      allow(Digidoc::Client).to receive(:new) { client }

      visit registrar_login_path
      page.should have_css('a[href="/registrar/login/mid"]')

      page.find('a[href="/registrar/login/mid"]').click

      fill_in 'user_phone', with: '00007'
      click_button 'Login'

      page.should have_text('Confirmation sms was sent to your phone. Verification code is')
    end
  end
end
