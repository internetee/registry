require 'rails_helper'

feature 'Domains', type: :feature do
  before :all do
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

      page.should_not have_text(d1.name)
      page.should have_text(d2.name)
    end
  end
end
