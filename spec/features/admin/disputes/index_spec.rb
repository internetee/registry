require 'rails_helper'

RSpec.feature 'Dispute list' do
  given!(:dispute) { create(:dispute) }

  scenario 'is visible' do
    sign_in_to_admin_area
    click_link_or_button 'Disputes'

    expect(page).to have_css('.dispute')
  end
end
