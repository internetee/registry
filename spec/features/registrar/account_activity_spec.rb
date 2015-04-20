require 'rails_helper'

feature 'Account activity', type: :feature do
  before :all do
    @user = Fabricate(:api_user)
    Fabricate(:account_activity, account: @user.registrar.cash_account)
  end

  context 'as unknown user' do
    it 'should redirect to sign in page' do
      visit '/registrar/account_activities'
      current_path.should == '/registrar/login'
      page.should have_text('You need to sign in or sign up')
    end
  end

  context 'as signed in user' do
    before do
      registrar_sign_in
    end

    it 'should navigate to account activities page' do
      current_path.should == '/registrar'
      click_link 'Billing'
      click_link 'Account activity'

      current_path.should == '/registrar/account_activities'
      page.should have_text('+110.0 EUR')
    end
  end
end
