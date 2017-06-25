require 'rails_helper'

RSpec.feature 'Edit dispute' do
  given!(:dispute) { create(:dispute) }

  it 'updates dispute' do
    sign_in_to_admin_area

    visit admin_disputes_url
    click_link_or_button 'Edit'

    click_link_or_button 'Update dispute'

    expect(page).to have_text('Dispute has been successfully updated')
  end
end
