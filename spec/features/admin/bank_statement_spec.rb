require 'rails_helper'

feature 'BankStatement', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  before do
    sign_in @user
  end

  it 'should add a bank statement and transactions manually' do
    visit admin_bank_statements_url

    click_link 'Add'
    fill_in 'Bank code', with: '767'
    fill_in 'Iban', with: 'EE557700771000598731'
    click_button 'Save'

    page.should have_content('Record created')
    page.should have_content('Bank statement ')
    page.should have_content('767')
    page.should have_content('EE557700771000598731')
    page.should have_content('Not binded')

    click_link 'Add'
    fill_in 'Description', with: 'Payment 12345'
    fill_in 'Sum', with: '120'
    fill_in 'Reference no', with: 'RF4663930489'
    fill_in 'Document no', with: '123'
    fill_in 'Bank reference', with: '767'
    fill_in 'Iban', with: 'EE557700771000598731'
    fill_in 'Buyer bank code', with: '767'
    fill_in 'Buyer iban', with: 'EE557700771000598000'
    fill_in 'Buyer name', with: 'Test buyer'
    fill_in 'Paid at', with: '2015-01-01'

    click_button 'Save'

    page.should have_content('Record created')
    page.should have_content('Bank transaction')
    page.should have_content('RF4663930489')
    page.should have_content('EE557700771000598000')
    page.should have_content('Not binded')
    page.should have_content('Bind manually')

    click_link 'Back to bank statement'

    page.should have_content('120.0')
    page.should have_content('Test buyer')
  end
end
