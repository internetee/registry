require 'rails_helper'

RSpec.feature 'Contact list', settings: false do
  given!(:registrar) { create(:registrar) }
  given!(:contact) { create(:contact, registrar: registrar) }

  background do
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance, registrar: registrar))
  end

  it 'is visible' do
    visit registrar_contacts_path
    expect(page).to have_css('.contacts')
  end
end
