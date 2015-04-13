require 'rails_helper'

feature 'Sessions', type: :feature do
  before :all do
    create_settings
    Fabricate(:api_user)
  end

  context 'as unknown user' do
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
      click_button 'Log in'
      page.should have_text('No such user')
    end
  end

  context 'as known api user' do
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
      click_button 'Log in'
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
      click_button 'Log in'

      page.should have_text('Check your phone for confirmation code')
      page.should have_text('SIM application error')
    end

    it 'should log in successfully', js: true do
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
      click_button 'Log in'

      page.should have_text('Check your phone for confirmation code')
      page.should have_text('Welcome!')
    end

    it 'should log in successfully using helper method with javascript off' do
      registrar_sign_in
      page.should have_text('Log out')
    end

    it 'should log in successfully using helper method with javascript on', js: true do
      # not working yet
      # registrar_sign_in
      # page.should have_text('Log out')
    end
  end
end
