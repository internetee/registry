require 'rails_helper'

feature 'Domains', type: :feature do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
    Fabricate(:zonefile_setting, origin: 'pri.ee')
    @user = Fabricate(:api_user)
  end

  context 'as unknown user' do
    it 'should redirect to sign in page' do
      visit '/registrar/domains'
      current_path.should == '/registrar/login'
      page.should have_text('You need to sign in or sign up')
    end
  end

  context 'as signed in user' do
    before do
      registrar_sign_in
    end

    it 'should navigate to the domains index page' do
      click_link 'Domains'
      current_path.should == '/registrar/domains'
    end

    it 'should get domains index page' do
      visit '/registrar/domains'
      current_path.should == '/registrar/domains'
    end

    it 'should navigate to new page' do
      click_link 'Domains'
      click_link 'New'

      current_path.should == '/registrar/domains/new'
    end

    it 'should get new page' do
      visit '/registrar/domains/new'
      current_path.should == '/registrar/domains/new'
    end

    it 'should switch user' do
      d1 = Fabricate(:domain, registrar: @user.registrar)
      user2 = Fabricate(:api_user, identity_code: @user.identity_code)
      d2 = Fabricate(:domain, registrar: user2.registrar)

      visit '/registrar/domains'

      page.should have_text(d1.name)
      page.should_not have_text(d2.name)

      click_link "#{user2} (#{user2.roles.first}) - #{user2.registrar}"

      visit '/registrar/domains'

      page.should_not have_text(d1.name)
      page.should have_text(d2.name)
    end

    it 'should search domains' do
      # having shared state across tests is really annoying sometimes...
      within('.dropdown-menu') do
        click_link "#{@user} (#{@user.roles.first}) - #{@user.registrar}"
      end

      Fabricate(:domain, name: 'abcde.ee', registrar: @user.registrar)
      Fabricate(:domain, name: 'abcdee.ee', registrar: @user.registrar)
      Fabricate(:domain, name: 'defgh.pri.ee', registrar: @user.registrar)

      visit '/registrar/domains'
      click_link 'Domains'

      page.should have_content('abcde.ee')
      page.should have_content('abcdee.ee')
      page.should have_content('defgh.pri.ee')

      fill_in 'q_name_matches', with: 'abcde.ee'
      find('.btn.btn-primary.search').click

      current_path.should == "/registrar/domains/info"

      visit '/registrar/domains'
      fill_in 'q_name_matches', with: '.ee'
      find('.btn.btn-primary.search').click

      current_path.should == "/registrar/domains"
      page.should have_content('abcde.ee')
      page.should have_content('abcdee.ee')
      page.should have_content('defgh.pri.ee')

      fill_in 'q_name_matches', with: 'abcd%.ee'
      find('.btn.btn-primary.search').click
      page.should have_content('abcde.ee')
      page.should have_content('abcdee.ee')
      page.should_not have_content('defgh.pri.ee')

      fill_in 'q_name_matches', with: 'abcd_.ee'
      find('.btn.btn-primary.search').click
      current_path.should == "/registrar/domains"
      page.should have_content('abcde.ee')
    end

    it 'should search foreign domain and transfer it' do
      user2 = Fabricate(:api_user, identity_code: @user.identity_code)
      d2 = Fabricate(:domain, registrar: user2.registrar)

      visit '/registrar/domains'
      page.should_not have_content(d2.name)
      fill_in 'q_name_matches', with: d2.name
      find('.btn.btn-primary.search').click

      current_path.should == "/registrar/domains/info"
      click_link 'Transfer'
      fill_in 'Password', with: d2.auth_info
      click_button 'Transfer'
      page.should have_content 'serverApproved'
      visit '/registrar/domains'
      page.should have_content d2.name
    end
  end
end
