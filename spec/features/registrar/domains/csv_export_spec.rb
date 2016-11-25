require 'rails_helper'

RSpec.feature 'CSV Export', db: true do
  scenario 'csv file download' do
    sign_in
    visit registrar_domains_path
    click_on 'export-domains-csv-btn'
  end

  def sign_in(user: create(:user_with_valid_password))
    visit registrar_login_path

    fill_in 'depp_user_tag', with: user.email
    fill_in 'depp_user_password', with: user.password

    click_button 'Login'
  end
end
