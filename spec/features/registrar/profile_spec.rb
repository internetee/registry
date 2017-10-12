require 'rails_helper'

RSpec.feature 'Registrar area profile', settings: false do
  background do
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance))
  end

  scenario 'shows profile' do
    visit registrar_root_path
    click_on 'registrar-profile-btn'
    expect(page).to have_text(t('registrar.profile.show.header'))
  end
end
