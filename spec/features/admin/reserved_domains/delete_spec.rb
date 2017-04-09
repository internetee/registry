require 'rails_helper'

RSpec.feature 'Delete reserved domain' do
  given!(:reserved_domain) { create(:reserved_domain) }

  background do
    sign_in_to_admin_area
  end

  scenario 'deleting reserved domain' do
    visit admin_reserved_domains_url
    click_link_or_button 'Delete'

    expect(page).to have_text('Reserved domain has been successfully deleted')
  end
end
