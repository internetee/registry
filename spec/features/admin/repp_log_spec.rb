require 'rails_helper'

feature 'Repp log', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit admin_repp_logs_url

      current_path.should == '/admin/login'
    end
  end

  context 'as logged in user' do
    it 'should show index' do
      sign_in @user
      visit admin_repp_logs_url

      page.should have_content('REPP logs')
    end
  end
end
