require 'rails_helper'

feature 'Admin contact', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
    @contact = Fabricate(:contact, name: 'Mr John')
  end

  it 'should show index of contacts' do
    sign_in @user
    visit admin_contacts_url

    page.should have_content('Mr John')
  end

  it 'should show correct contact creator' do
    sign_in @user
    visit admin_contacts_url

    click_link('Mr John')
    # initially it's created by unknown,
    # indivitually running it's created by autotest
    page.should have_content(/by [unknown|autotest]/)
  end

  it 'should search contacts by name' do
    d1 = Fabricate(:contact, name: 'first name')
    Fabricate(:contact, name: 'second name')
    Fabricate(:contact, name: 'third name')
    sign_in @user
    visit admin_contacts_url

    page.should have_content('first name')
    page.should have_content('second name')
    page.should have_content('third name')

    fill_in 'q_name_matches', with: 'first name'
    find('.btn.btn-primary').click

    current_path.should == "/admin/contacts"

    page.should have_content('first name')
    page.should_not have_content('second name')
    page.should_not have_content('third name')

    fill_in 'q_name_matches', with: '%name'
    find('.btn.btn-primary').click

    page.should have_content('first name')
    page.should have_content('second name')
    page.should have_content('third name')

    fill_in 'q_name_matches', with: 'sec___ name'
    find('.btn.btn-primary').click

    page.should_not have_content('first name')
    page.should have_content('second name')
    page.should_not have_content('third name')
  end
end
