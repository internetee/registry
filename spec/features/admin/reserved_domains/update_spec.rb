require 'rails_helper'

RSpec.feature 'Update reserved domain' do
  given!(:reserved_domain) { create(:reserved_domain) }

  it 'updates reserved domain' do
    sign_in_to_admin_area

    visit admin_reserved_domains_url
    click_link_or_button 'Edit'

    click_link_or_button 'Save'

    expect(page).to have_text('Reserved domain has been successfully updated')
  end
end
