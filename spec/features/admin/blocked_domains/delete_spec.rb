require 'rails_helper'

RSpec.feature 'Delete blocked domain' do
  given!(:blocked_domain) { create(:blocked_domain) }

  background do
    sign_in_to_admin_area
  end

  scenario 'deleting blocked domain' do
    visit admin_blocked_domains_url
    click_link_or_button 'Delete'

    expect(page).to have_text('Blocked domain has been successfully deleted')
  end
end
