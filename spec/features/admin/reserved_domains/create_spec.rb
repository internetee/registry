require 'rails_helper'

RSpec.feature 'New reserved domain' do
  it 'creates new reserved domain' do
    sign_in_to_admin_area

    visit admin_reserved_domains_url
    click_link_or_button 'New reserved domain'

    fill_in 'reserved_domain[name]', with: 'test.com'
    click_link_or_button 'Save'

    expect(page).to have_text('Reserved domain has been successfully created')
  end
end
