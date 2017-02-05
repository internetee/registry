require 'rails_helper'

RSpec.feature 'New dispute' do
  given!(:domain) { create(:domain, name: 'test.com') }

  background do
    travel_to Time.zone.parse('05.07.2010')
  end

  it 'creates new dispute' do
    sign_in_to_admin_area

    visit admin_disputes_url
    click_link_or_button 'New dispute'

    fill_in 'dispute[domain_name]', with: 'test.com'
    fill_in 'dispute[expire_date]', with: localize(Date.parse('05.07.2010'))
    fill_in 'dispute[password]', with: 'test'
    click_link_or_button 'Create dispute'

    expect(page).to have_text('Dispute has been successfully created')
  end
end
