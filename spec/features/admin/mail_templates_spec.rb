require 'rails_helper'

feature 'MailTemplate', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  before do
    sign_in @user
  end

  it 'should add a bank statement and transactions manually' do
    visit admin_mail_templates_url

    click_link 'New'
    fill_in 'Name', with: 'Testing email template'
    fill_in 'Subject', with: 'Test subject'
    fill_in 'From', with: 'example@example.com'
    fill_in 'mail_template_body', with: 'Liquid <h1>Test</h1>'
    fill_in 'mail_template_text_body', with: 'Liquid static test'
    click_button 'Save'

    page.should have_content('Testing email template')
    page.should have_content('Test subject')
    page.should have_content('example@example.com')
    page.should have_content('Liquid Test')
    page.should have_content('Liquid static test')

    click_link 'Email Templates'
    page.should have_content('Mail Templates')
    page.should have_content('Test subject')

    click_link 'Testing email template'
    page.should have_content('Testing email template')

    click_link 'Edit'
    page.should have_content('Edit: Testing email template')
    fill_in 'Subject', with: 'New edited test subject'
    click_button 'Save'

    page.should have_content 'New edited test subject'
    click_link 'Delete'

    page.should have_content 'Mail Templates'
    page.should_not have_content 'New edited test subject'
  end
end
