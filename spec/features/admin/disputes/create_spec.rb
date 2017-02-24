require 'rails_helper'

RSpec.feature 'New dispute' do
  background do
    sign_in_to_admin_area
    travel_to Time.zone.parse('05.07.2010')
  end

  it 'creates new dispute' do
    visit admin_disputes_url
    click_link_or_button 'New dispute'

    fill_in 'dispute[domain_name]', with: 'test.com'
    fill_in 'dispute[expire_date]', with: localize(Date.parse('05.07.2010'))
    fill_in 'dispute[password]', with: 'test'
    fill_in 'dispute[comment]', with: 'test'
    click_link_or_button 'Create dispute'

    expect(page).to have_text('Dispute has been successfully created')
  end

  context 'when zone is not supported' do
    it 'shows error' do
      visit admin_disputes_url
      click_link_or_button 'New dispute'

      fill_in 'dispute[domain_name]', with: 'test.unsupported'
      click_link_or_button 'Create dispute'

      expect(page).to have_text('Domain name has unsupported zone')
    end
  end

  context 'when expiration date is in the past' do
    it 'shows error' do
      visit admin_disputes_url
      click_link_or_button 'New dispute'

      fill_in 'dispute[expire_date]', with: localize(Date.parse('04.07.2010'))
      click_link_or_button 'Create dispute'

      expect(page).to have_text('Exp. date cannot be in the past')
    end
  end
end
