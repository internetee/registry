require 'rails_helper'

RSpec.feature 'Registrant whois search' do
  background do
    sign_in_to_registrant_area
    create(:whois_record, domain_name: 'test.com', body: 'test.com whois data')
  end

  it 'searches for domain name' do
    visit registrant_whois_url

    fill_in 'domain_name', with: 'test.com'
    click_link_or_button 'registrant-whois-search-btn'

    expect(page).to have_text('test.com whois data')
  end
end
