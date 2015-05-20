require 'rails_helper'

feature 'Api users', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
    @api_user = Fabricate(:api_user)
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit admin_api_users_url

      current_path.should == '/admin/login'
    end

    it 'should redirect to login path' do
      visit admin_api_user_url(@api_user)

      current_path.should == '/admin/login'
    end

  end

  context 'as logged in user' do
    it 'should show index of api users' do
      sign_in @user
      visit admin_api_users_url

      current_path.should == '/admin/api_users'
      page.should have_content('API users')
    end

    it 'should show api user' do
      sign_in @user
      visit admin_api_user_url(@api_user)

      current_path.should == "/admin/api_users/#{@api_user.id}"
    end
  end
end
