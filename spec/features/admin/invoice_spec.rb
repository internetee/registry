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

  it 'should create bank statement and transaction for invoice' do
    r = Fabricate(:registrar, reference_no: 'RF7086666663')
    invoice = r.issue_prepayment_invoice(200, 'add some money')

    visit '/admin/invoices'
    click_link invoice.to_s

    page.should have_content('Unpaid')

    click_link 'Payment received'

    paid_at = Time.zone.now
    find_field('Bank code').value.should == '689'
    find_field('Iban').value.should == 'EE557700771000598731'
    find_field('Description').value.should == invoice.to_s
    find_field('Sum').value.should == invoice.sum.to_s
    find_field('Currency').value.should == 'EUR'
    find_field('Reference no').value.should == invoice.reference_no
    find_field('Paid at').value.should == paid_at.to_date.to_s

    click_button 'Save'

    page.should have_content('Record created')
    page.should have_content('689')
    page.should have_content('EE557700771000598731')
    page.should have_content('Not binded', count: 2)
    page.should have_content(invoice.sum.to_s)
    page.should have_content('EUR')

    click_link 'Bind invoices'

    page.should have_content('Invoices were fully binded')
    page.should have_content('Fully binded')
    page.should have_content('Binded')

    click_link I18n.l(paid_at, format: :date_long)

    page.should have_content('Binded')
    page.should have_content(invoice.to_s)
    page.should have_content(invoice.sum.to_s)
    page.should have_content(invoice.reference_no)
    page.should have_content(I18n.l(paid_at, format: :date_long))

    click_link(invoice.to_s)
    page.should_not have_content('Unpaid')
    page.should_not have_content('Payment received')
  end
end
