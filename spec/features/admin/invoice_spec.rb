require 'rails_helper'

feature 'Invoice', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
    Fabricate(:invoice)
  end

  before do
    sign_in @user
  end

  it 'should show index of invoices' do
    visit admin_invoices_url
    i = Invoice.first
    page.should have_link("Invoice no. #{i.id}")
  end

  it 'should show invoice' do
    visit admin_invoices_url
    i = Invoice.first

    click_link("Invoice no. #{i.id}")
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
end
