require 'rails_helper'

feature 'Invoice', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
    @invoice = Fabricate(:invoice)
  end

  before do
    sign_in @user
  end

  it 'should show index of invoices' do
    visit admin_invoices_url
    page.should have_link("Invoice no. #{@invoice.id}")
  end

  it 'should show invoice' do
    visit admin_invoices_url

    click_link("Invoice no. #{@invoice.id}")
    page.should have_content("Seller")
    page.should have_content("Details")
    page.should have_content("Paldiski mnt. 123")
  end

  it 'should issue an invoice' do
    Fabricate(:eis)
    r = Fabricate(:registrar)
    visit admin_invoices_url
    click_link('Add')
    page.should have_content('Create new invoice')
    select r.name, from: 'Registrar'
    fill_in 'Amount', with: '100'
    fill_in 'Description', with: 'test issue'
    click_button 'Save'
    page.should have_content('Record created')
    page.should have_content('Invoice no.')
    page.should have_content('Prepayment')
    page.should have_content('120.0')
    page.should have_content(r.name)
  end

  it 'should forward invoice' do
    visit '/admin/invoices'
    click_link @invoice.to_s
    click_link 'Forward'
    click_button 'Forward'
    page.should have_text('Failed to forward invoice')
    fill_in 'Billing email', with: 'test@test.ee'
    click_button 'Forward'
    page.should have_text('Invoice forwarded')
  end

  it 'should download invoice' do
    visit '/admin/invoices'
    click_link @invoice.to_s
    click_link 'Download'
    response_headers['Content-Type'].should == 'application/pdf'
    response_headers['Content-Disposition'].should == "attachment; filename=\"#{@invoice.pdf_name}\""
  end
end
