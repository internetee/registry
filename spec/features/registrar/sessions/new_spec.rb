require 'rails_helper'

RSpec.feature 'Registrar area ip restriction', settings: false do
  context 'when enabled' do
    background do
      Setting.registrar_ip_whitelist_enabled = true
    end

    context 'when ip is allowed' do
      given!(:white_ip) { create(:white_ip,
                                 ipv4: '127.0.0.1',
                                 interfaces: [WhiteIp::REGISTRAR]) }

      it 'does not show error message' do
        visit registrar_login_path
        expect(page).to_not have_text(error_message)
      end
    end

    context 'when ip is not allowed' do
      it 'shows error message' do
        visit registrar_login_path
        expect(page).to have_text(error_message)
      end
    end
  end

  context 'when disabled' do
    background do
      Setting.registrar_ip_whitelist_enabled = false
    end

    it 'does not show error message' do
      visit registrar_login_path
      expect(page).to_not have_text(error_message)
    end
  end

  def error_message
    t('registrar.authorization.ip_not_allowed', ip: '127.0.0.1')
  end
end
