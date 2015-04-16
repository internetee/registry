require 'rails_helper'

feature 'Admin users', type: :feature do
  background { create_settings }

  before :all do
    @admin_user = Fabricate(:admin_user, username: 'user1', identity_code: '37810013087')
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit admin_admin_users_url
      current_path.should == '/admin/login'
    end

    it 'should redirect to login path' do
      visit admin_admin_user_url(@admin_user)
      current_path.should == '/admin/login'
    end

    it 'should redirect to login path' do
      visit edit_admin_admin_user_url(@admin_user)
      current_path.should == '/admin/login'
    end
  end

  context 'as logged in user' do
    it 'should show index of contacts' do
      sign_in @admin_user
      visit admin_admin_users_url

      current_path.should == '/admin/admin_users'
      page.should have_content('API users')
    end

    it 'should show api user' do
      sign_in @admin_user
      visit admin_admin_user_url(@admin_user)

      current_path.should == "/admin/admin_users/#{@admin_user.id}"
    end

    it 'should show api user' do
      sign_in @admin_user
      visit edit_admin_admin_user_url(@admin_user)

      current_path.should == "/admin/admin_users/#{@admin_user.id}/edit"
      page.should have_content("Edit: #{@admin_user.username}")
    end
  end
end
