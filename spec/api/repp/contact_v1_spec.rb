require 'rails_helper'

RSpec.describe Repp::ContactV1, db: true do
  let(:user) { create(:api_user, registrar: registrar) }
  let(:registrar) { create(:registrar) }

  describe '/contacts' do
    let(:returned_attributes) { HashWithIndifferentAccess.new(JSON.parse(response.body)['contacts'].first).keys }
    subject(:address_included) { Contact.address_attribute_names.any? { |attr| returned_attributes.include?(attr.to_s) } }

    before do
      Grape::Endpoint.before_each do |endpoint|
        allow(endpoint).to receive(:current_user).and_return(user)
      end

      registrar.contacts << create(:contact)
    end

    it 'responds with success' do
      get '/repp/v1/contacts', { limit: 1, details: true }, { 'HTTP_AUTHORIZATION' => http_auth_key }
      expect(response).to have_http_status(:success)
    end

    context 'when address processing is enabled' do
      before do
        expect(Contact).to receive(:address_processing?).and_return(true)
        get '/repp/v1/contacts', { limit: 1, details: true }, { 'HTTP_AUTHORIZATION' => http_auth_key }
      end

      it 'returns contact address' do
        expect(address_included).to be_truthy
      end
    end

    context 'when address processing is disabled' do
      before do
        expect(Contact).to receive(:address_processing?).and_return(false)
        get '/repp/v1/contacts', { limit: 1, details: true }, { 'HTTP_AUTHORIZATION' => http_auth_key }
      end

      it 'does not return contact address' do
        expect(address_included).to be_falsy
      end
    end
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password)
  end
end
