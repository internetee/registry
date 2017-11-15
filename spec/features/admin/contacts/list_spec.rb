require 'rails_helper'

RSpec.feature 'Contact list', settings: false do
  background do
    sign_in_to_admin_area
  end

  it 'is visible' do
    visit admin_contacts_path
    expect(page).to have_css('.contacts')
  end
end
