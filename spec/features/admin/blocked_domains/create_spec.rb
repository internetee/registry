require 'rails_helper'

RSpec.feature 'New blocked domain' do
  it 'creates new blocked domain' do
    sign_in_to_admin_area

    visit admin_blocked_domains_url
    click_link_or_button 'New blocked domain'

    fill_in 'blocked_domain[name]', with: 'test.com'
    click_link_or_button 'Save'

    expect(page).to have_text('Blocked domain has been successfully created')
  end
end
