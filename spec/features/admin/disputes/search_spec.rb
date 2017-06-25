require 'rails_helper'

RSpec.feature 'Dispute search' do
  background do
    sign_in_to_admin_area
    visit admin_disputes_url
  end

  feature 'by domain name' do
    background do
      create(:dispute, domain_name: 'example-test.com')
      create(:dispute, domain_name: 'another.com')
    end

    it 'shows matched disputes' do
      fill_in 'search[domain_name]', with: 'test'
      click_link_or_button 'Search'

      expect(page).to have_css('.dispute', count: 1)
    end
  end

  feature 'by expiration date range' do
    background do
      create(:dispute, expire_date: Date.parse('04.07.2010'))
      create(:dispute, expire_date: Date.parse('05.07.2010'))
      create(:dispute, expire_date: Date.parse('06.07.2010'))
      create(:dispute, expire_date: Date.parse('07.07.2010'))
    end

    it 'shows matched disputes' do
      fill_in 'search[expire_date_start]', with: localize(Date.parse('05.07.2010'))
      fill_in 'search[expire_date_end]', with: localize(Date.parse('06.07.2010'))
      click_link_or_button 'Search'

      expect(page).to have_css('.dispute', count: 2)
    end
  end

  feature 'reset' do
    it 'resets form' do
      click_link_or_button 'Reset'
      expect(find('[name="search[domain_name]"]').value).to be_blank
    end
  end
end
