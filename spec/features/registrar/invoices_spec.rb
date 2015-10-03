require 'rails_helper'

feature 'Invoices', type: :feature do
  before :all do
    @user = Fabricate(:api_user)
    @invoice = Fabricate(:invoice, buyer: @user.registrar)
  end

  context 'as unknown user' do
    it 'should redirect to sign in page' do
      visit '/registrar/invoices'
      current_path.should == '/registrar/login'
      page.should have_text('You need to sign in or sign up')
    end
  end

  context 'as signed in user' do
    before do
      registrar_sign_in
    end

    it 'should navigate to the domains index page' do
      current_path.should == '/registrar/poll'
      click_link 'Billing'

      current_path.should == '/registrar/invoices'
      page.should have_text('Your current account balance is')
    end

    it 'should get domains index page' do
      visit '/registrar/invoices'
      page.should have_text('Invoices')
    end

    it 'should forward invoice' do
      visit '/registrar/invoices'
      click_link @invoice.to_s
      click_link 'Forward'
      click_button 'Forward'
      page.should have_text('Failed to forward invoice')
      fill_in 'Billing email', with: 'test@test.ee'
      click_button 'Forward'
      page.should have_text('Invoice forwarded')
    end

    it 'should download invoice' do
      visit '/registrar/invoices'
      click_link @invoice.to_s
      click_link 'Download'
      response_headers['Content-Type'].should == 'application/pdf'
      response_headers['Content-Disposition'].should == "attachment; filename=\"#{@invoice.pdf_name}\""
    end

    it 'should not see foreign invoices' do
      user2 = Fabricate(:api_user, identity_code: @user.identity_code)
      visit '/registrar/invoices'
      click_link @invoice.to_s
      page.should have_text(@invoice.to_s)
      page.should have_text('Buyer')
      click_link "#{user2} (#{user2.roles.first}) - #{user2.registrar}"
      visit "/registrar/invoices/#{@invoice.id}"
      page.should have_text('You are not authorized to access this page.')

      visit "/registrar/invoices/#{@invoice.id}/forward"
      page.should have_text('You are not authorized to access this page.')
    end
  end
end
