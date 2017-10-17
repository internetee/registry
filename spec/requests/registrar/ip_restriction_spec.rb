require 'rails_helper'

RSpec.describe 'Registrar area IP restriction', settings: false do
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
                                 registrar: controller.current_user.registrar,
                                 interfaces: [WhiteIp::REGISTRAR]) }

        specify do
          get registrar_root_url
          follow_redirect!
          expect(response).to be_success
        end
      end

      context 'when ip is not allowed' do
        it 'signs the user out' do
          get registrar_root_url
          follow_redirect!
          expect(controller.current_user).to be_nil
        end

        it 'redirects to login url' do
          get registrar_root_url
          expect(response).to redirect_to(registrar_login_url)
        end
      end
    end

    context 'when IP restriction is disabled' do
      before do
        Setting.registrar_ip_whitelist_enabled = false
      end

      specify do
        get registrar_root_url
        follow_redirect!
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
          get registrar_login_path
          expect(response).to be_success
        end
      end

      context 'when ip is not allowed' do
        specify do
          get registrar_login_path
          expect(response.body).to match "Access denied"
        end
      end
    end

    context 'when IP restriction is disabled' do
      before do
        Setting.registrar_ip_whitelist_enabled = false
      end

      specify do
        get registrar_login_path
        expect(response).to be_success
      end
    end
  end
end
