require 'rails_helper'

RSpec.feature 'Registrar area IP restriction', settings: false do
  before do
    @original_registrar_ip_whitelist_enabled = Setting.registrar_ip_whitelist_enabled
  end

  after do
    Setting.registrar_ip_whitelist_enabled = @original_registrar_ip_whitelist_enabled
  end

  scenario 'notifies the user if his IP is not allowed' do
    Setting.registrar_ip_whitelist_enabled = true
    visit registrar_root_path
    expect(page).to have_text('Access denied from IP 127.0.0.1')
  end
end
