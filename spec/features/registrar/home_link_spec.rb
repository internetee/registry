require 'rails_helper'

RSpec.feature 'Registrar area home link', db: true do
  scenario 'is visible' do
    visit registrar_login_url
    expect(page).to have_link('registrar-home-btn', href: registrar_root_path)
  end
end
