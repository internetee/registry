require 'rails_helper'

RSpec.feature 'CSV Export', db: true do
  background do
    sign_in(user: FactoryGirl.create(:api_user))
  end

  scenario 'csv file download' do
    visit registrar_domains_path
    click_on 'export-domains-csv-btn'
  end
end
