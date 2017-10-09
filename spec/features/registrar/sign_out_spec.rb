require 'rails_helper'

RSpec.feature 'Registrar area sign-out', settings: false do
  background do
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance))
  end

  scenario 'signs the user out' do
    visit registrar_root_path
    click_on t('registrar.base.current_user.sign_out')

    expect(page).to have_text('Signed out successfully.')
  end
end
