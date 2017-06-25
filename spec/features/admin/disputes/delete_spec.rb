require 'rails_helper'

RSpec.feature 'Delete dispute' do
  given!(:dispute) { create(:dispute) }

  scenario 'deleting dispute' do
    sign_in_to_admin_area

    visit admin_disputes_url
    click_link_or_button 'Delete'

    expect(page).to have_text('Dispute has been successfully deleted')
  end
end
