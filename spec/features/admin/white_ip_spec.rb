require 'rails_helper'

feature 'Api users', type: :feature do
  before :all do
    @user = Fabricate(:admin_user, username: 'user1', identity_code: '37810013087')
    @registrar = Fabricate(:registrar)
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit new_admin_registrar_white_ip_url(@registrar)

      current_path.should == '/admin/login'
    end
  end

  context 'as logged in user' do
    before { sign_in @user }

    it 'should add new white ip to registrar' do
      visit admin_registrar_url(@registrar)

      page.should_not have_text('192.168.1.1')

      click_link 'Create new white IP'

      fill_in 'IPv4', with: '192.168.1.1'
      fill_in 'IPv6', with: 'FE80:0000:0000:0000:0202:B3FF:FE1E:8329'
      select 'REPP', from: 'Interface'
      click_button 'Save'

      page.should have_text('Record created')
      page.should have_text('White IP')
      page.should have_link(@registrar.to_s)
      page.should have_text('192.168.1.1')
      page.should have_text('FE80:0000:0000:0000:0202:B3FF:FE1E:8329')
      page.should have_text('REPP')

      click_link @registrar.to_s

      current_path.should == "/admin/registrars/#{@registrar.id}"
      page.should have_text('192.168.1.1')
      page.should have_text('FE80:0000:0000:0000:0202:B3FF:FE1E:8329')
      page.should have_text('REPP')
    end

    it 'should not add invalid ip to registrar' do
      visit new_admin_registrar_white_ip_url(@registrar)

      click_button 'Save'
      page.should have_text('IPv4 or IPv6 must be present')
      page.should have_text('Failed to create record')

      fill_in 'IPv4', with: 'bla'
      fill_in 'IPv6', with: 'bla'

      click_button 'Save'

      page.should have_text('IPv4 is invalid')
      page.should have_text('IPv6 is invalid')
    end
  end
end
