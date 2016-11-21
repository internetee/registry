require 'rails_helper'

RSpec.feature 'CSV Export', db: true do
  scenario 'csv file download' do
    visit registrar_domains_path
    click_on 'download-domains-csv-btn'
  end
end
