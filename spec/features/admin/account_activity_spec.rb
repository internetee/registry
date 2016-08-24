require 'rails_helper'

feature 'Account activity', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
    r = Fabricate(:registrar)
    Fabricate.times(5, :account_activity, account: r.cash_account)
    Fabricate(:account_activity, account: r.cash_account, description: 'acc activity test', sum: -12)
  end

  context 'as unknown user' do
    it 'should redirect to sign in page' do
      visit '/admin/account_activities'
      current_path.should == '/admin/login'
      page.should have_text('You need to sign in')
    end
  end

  context 'as signed in user' do
    before do
      sign_in @user
    end

    it 'should navigate to account activities page' do
      visit admin_account_activities_path
      page.should have_text('+110.0 EUR', count: 5)
      page.should have_text('-12.0 EUR')
    end

    it 'should search activities by description' do
      visit admin_account_activities_path
      fill_in 'Description', with: 'test'
      find('.btn.btn-default.search').click
      page.should have_text('-12.0 EUR')
      page.should_not have_text('+110.0 EUR')
    end

    it 'should download csv' do
      visit admin_account_activities_path
      click_link 'Export CSV'
      response_headers['Content-Type'].should == 'text/csv'
      response_headers['Content-Disposition'].should match(/attachment; filename="account_activities_\d+\.csv"/)
    end
  end
end
