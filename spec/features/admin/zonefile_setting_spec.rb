require 'rails_helper'

feature 'Zonefile settings', type: :feature do
  before :all do
    @user = Fabricate(:admin_user, username: 'user1', identity_code: '37810013087')
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit admin_zonefile_settings_url

      current_path.should == '/admin/login'
    end
  end

  context 'as logged in user' do
    it 'should show index of contacts' do
      sign_in @user
      visit admin_zonefile_settings_url

      page.should have_content('Zonefile settings')
    end
  end
end
