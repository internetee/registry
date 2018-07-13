require 'rails_helper'

RSpec.describe 'Registrar area linked users', db: false do
  describe 'user switch' do
    context 'when user is authenticated', db: true do
      let!(:current_user) { create(:api_user, id: 1, identity_code: 'code') }

      before do
        sign_in current_user
      end

      context 'when ip is allowed' do
        let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                              can_access_registrar_area?: true) }

        before do
          allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
        end

        context 'when new user is linked' do
          let!(:new_user) { create(:api_user, id: 2, identity_code: 'code') }

          it 'signs in as a new user' do
            put '/registrar/current_user/switch/2', nil, { HTTP_REFERER: registrar_contacts_url }
            follow_redirect!
            expect(controller.current_registrar_user.id).to eq(2)
          end

          it 'redirects back' do
            put '/registrar/current_user/switch/2', nil, { HTTP_REFERER: 'http://previous.url' }
            expect(response).to redirect_to('http://previous.url')
          end
        end

        context 'when new user is unlinked' do
          let!(:new_user) { create(:api_user, id: 2, identity_code: 'another-code') }

          it 'throws exception' do
            expect do
              put '/registrar/current_user/switch/2', nil, { HTTP_REFERER: registrar_contacts_path }
            end.to raise_error('Cannot switch to unlinked user')
          end
        end
      end

      context 'when ip is not allowed' do
        let(:restricted_ip) { instance_double(Authorization::RestrictedIP,
                                              can_access_registrar_area?: false) }

        before do
          allow(Authorization::RestrictedIP).to receive(:new).and_return(restricted_ip)
        end

        specify do
          put '/registrar/current_user/switch/2'
          expect(response).to redirect_to(new_registrar_user_session_url)
        end
      end
    end

    context 'when user is not authenticated' do
      specify do
        put '/registrar/current_user/switch/2'
        expect(response).to redirect_to(new_registrar_user_session_url)
      end
    end
  end
end
