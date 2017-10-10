require 'rails_helper'

RSpec.feature 'Registrar area IP restriction', settings: false do
  background do
    Setting.registrar_ip_whitelist_enabled = true
  end

  scenario 'notifies the user if his IP is not allowed' do
    visit registrar_root_path
    expect(page).to have_text('Access denied from IP 127.0.0.1')
  end
end
