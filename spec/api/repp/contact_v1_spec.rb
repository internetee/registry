require 'rails_helper'

RSpec.describe Repp::ContactV1, db: true do
  let(:user) { FactoryGirl.create(:api_user, registrar: registrar) }
  let(:registrar) { FactoryGirl.create(:registrar) }

  describe '/contacts' do
    subject(:fields) { HashWithIndifferentAccess.new(JSON.parse(response.body)['contacts'].first).keys }

    before do
      Grape::Endpoint.before_each do |endpoint|
        allow(endpoint).to receive(:current_user).and_return(user)
      end

      registrar.contacts << FactoryGirl.create(:contact)

      get '/repp/v1/contacts', { limit: 1, details: true }, { 'HTTP_AUTHORIZATION' => http_auth_key }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    context 'when address processing is enabled' do
      before do
        expect(Contact).to receive(:address_processing).and_return(true)
      end

      it 'returns contact address' do
        expect(fields).to include(Contact.address_attributes)
      end
    end

    context 'when address processing is disabled' do
      before do
        expect(Contact).to receive(:address_processing).and_return(false)
      end

      it 'does not return contact address' do
        expect(fields).to_not include(Contact.address_attributes)
      end
    end
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password)
  end
end
