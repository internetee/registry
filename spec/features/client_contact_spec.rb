require 'rails_helper'

feature 'Contact management', type: :feature do
  #background do
  #end

  before(:each) do
    Fabricate(:user, country: Fabricate(:country, iso: 'EE'), admin: false, username: 'zone')
    visit login_path
    click_on 'ID card (zone)'
  end

  scenario 'User sees contacts', js: true do
    Fabricate(:contact, registrar: Registrar.first)
    Fabricate(:contact, registrar: Registrar.first)
    visit client_contacts_path
    expect(page).to have_text(Contact.first.name)
    expect(page).to have_text(Contact.second.name)
  end

  scenario 'User creates contact', js: true do
    visit client_contacts_path
    click_on 'Create new contact'
    fill_in('Name', with: 'John Doe The Third')
    fill_in('Email', with: 'john@doe.eu')
    fill_in('Phone', with: '+123.3213123')
    fill_in('Ident', with: '312313')
    click_on 'Save'

    expect(current_path).to eq client_contact_path(Contact.first)

    expect(page).to have_text('Contact added!')
    expect(page).to have_text('Contact details')
    expect(page).to have_text('John Doe The Third')

    expect(Contact.first.registrar).to eq Registrar.first
  end
end
