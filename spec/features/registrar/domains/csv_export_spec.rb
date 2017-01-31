require 'rails_helper'

RSpec.feature 'CSV Export' do
  background do
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance))
  end

  scenario 'exports csv' do
    visit registrar_domains_url
    click_link_or_button 'Download'
  end
end
