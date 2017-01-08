require 'rails_helper'

RSpec.feature 'CSV Export' do
  background do
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance))
  end

  scenario 'exports csv' do
    visit registrar_domains_url
    click_button t('registrar.domains.index.export_csv_btn')
  end
end
