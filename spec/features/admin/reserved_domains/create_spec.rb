require 'rails_helper'

RSpec.feature 'New reserved domain' do
  background do
    sign_in_to_admin_area
  end

  it 'creates new reserved domain' do
    visit admin_reserved_domains_url
    click_link_or_button 'New reserved domain'

    fill_in 'reserved_domain[name]', with: 'test.com'
    click_link_or_button 'Save'

    expect(page).to have_text('Reserved domain has been successfully created')
  end

  context 'when domain name is disputed and password is given' do
    given!(:dispute) { create(:dispute, domain_name: 'test.com') }

    it 'creates new reserved domain' do
      visit admin_reserved_domains_url
      click_link_or_button 'New reserved domain'

      fill_in 'reserved_domain[name]', with: 'test.com'
      fill_in 'reserved_domain[password]', with: 'test'
      click_link_or_button 'Save'

      expect(page).to have_text('Reserved domain has been successfully created,' \
                                ' but the provided password has been discarded in favor of one from dispute')
    end
  end
end
