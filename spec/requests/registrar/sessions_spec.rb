require 'rails_helper'

RSpec.describe 'Registrar session management', db: false do
  describe 'GET /registrar/login' do
    context 'when ip is allowed' do
      let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                            can_access_registrar_area_sign_in_page?: true) }

      before do
        allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
      end

      specify do
        get registrar_login_path
        expect(response).to be_success
      end
    end

    context 'when ip is not allowed' do
      let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                            can_access_registrar_area_sign_in_page?: false) }

      before do
        allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
      end

      specify do
        get registrar_login_path
        expect(response).to be_forbidden
      end
    end
  end

  describe 'POST /registrar/sessions' do
    context 'when ip is allowed' do
      let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                            can_access_registrar_area_sign_in_page?: true) }

      before do
        allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
      end

      specify do
        make_request
        expect(response).to be_success
      end
    end

    context 'when ip is not allowed' do
      let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                            can_access_registrar_area_sign_in_page?: false) }

      before do
        allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
      end

      specify do
        make_request
        expect(response).to be_forbidden
      end
    end

    def make_request
      post registrar_sessions_path, depp_user: { tag: 'test', password: 'test' }
    end
  end
end
