require 'rails_helper'

RSpec.describe 'Registrar current user', db: false do
  describe 'GET /registrar/current_user/switch/2' do
    context 'when user is authenticated', db: true do
      let!(:current_user) { create(:api_user, id: 1, identity_code: 'test') }
      let!(:new_user) { create(:api_user, id: 2, identity_code: 'test') }

      before do
        sign_in_to_registrar_area(user: current_user)
      end

      context 'when ip is allowed' do
        let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                              can_access_registrar_area?: true) }

        before do
          allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
        end

        specify do
          make_request
          expect(response).to redirect_to('http://previous.url')
        end
      end

      context 'when ip is not allowed' do
        let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                              can_access_registrar_area?: false) }

        before do
          allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
        end

        specify do
          make_request
          expect(response).to redirect_to(registrar_login_url)
        end
      end
    end

    context 'when user is not authenticated' do
      specify do
        make_request
        expect(response).to redirect_to(registrar_login_url)
      end
    end

    def make_request
      get '/registrar/current_user/switch/2', nil, { 'HTTP_REFERER' => 'http://previous.url' }
    end
  end
end
