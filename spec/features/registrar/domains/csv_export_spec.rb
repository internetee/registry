require 'rails_helper'

RSpec.feature 'CSV Export', db: true do
  background do
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: FactoryGirl.create(:api_user))
  end

  scenario 'exports csv' do
    visit registrar_domains_url
    click_button t('registrar.domains.index.export_csv_btn')
  end
end
