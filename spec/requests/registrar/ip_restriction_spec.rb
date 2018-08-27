require 'rails_helper'

RSpec.describe 'Registrar area IP restriction', settings: false do
  before do
    @original_registrar_ip_whitelist_enabled_setting = Setting.registrar_ip_whitelist_enabled
  end

  after do
    Setting.registrar_ip_whitelist_enabled = @original_registrar_ip_whitelist_enabled_setting
  end

  context 'when authenticated' do
    before do
      sign_in_to_registrar_area
    end

    context 'when IP restriction is enabled' do
      before do
        Setting.registrar_ip_whitelist_enabled = true
      end

      context 'when ip is allowed' do
        let!(:white_ip) { create(:white_ip,
                                 ipv4: '127.0.0.1',
                                 registrar: controller.current_registrar_user.registrar,
                                 interfaces: [WhiteIp::REGISTRAR]) }

        specify do
          get registrar_root_url
          expect(response).to be_success
        end
      end

      context 'when ip is not allowed' do
        it 'signs the user out' do
          get registrar_root_url
          expect(controller.current_registrar_user).to be_nil
        end

        it 'redirects to login url' do
          get registrar_root_url
          expect(response).to redirect_to(new_registrar_user_session_url)
        end
      end
    end

    context 'when IP restriction is disabled' do
      specify do
        get registrar_root_url
        expect(response).to be_success
      end
    end
  end

  context 'when unauthenticated' do
    context 'when IP restriction is enabled' do
      before do
        Setting.registrar_ip_whitelist_enabled = true
      end

      context 'when ip is allowed' do
        let!(:white_ip) { create(:white_ip,
                                 ipv4: '127.0.0.1',
                                 interfaces: [WhiteIp::REGISTRAR]) }

        specify do
          get new_registrar_user_session_path
          expect(response).to be_success
        end
      end

      context 'when ip is not allowed' do
        specify do
          get new_registrar_user_session_path
          expect(response.body).to match "Access denied"
        end
      end
    end

    context 'when IP restriction is disabled' do
      specify do
        get new_registrar_user_session_path
        expect(response).to be_success
      end
    end
  end
end
