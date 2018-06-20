require 'rails_helper'

RSpec.feature 'Registrar area home link', db: true do
  scenario 'is visible' do
    visit new_registrar_user_session_url
    expect(page).to have_link('registrar-home-btn', href: registrar_root_path)
  end
end
