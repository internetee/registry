require 'rails_helper'

describe Repp::ContactV1 do
  let(:epp_user) { Fabricate(:epp_user) }

  before(:each) { create_settings }

  describe 'GET /repp/v1/contacts' do
    it 'returns contacts of the current registrar' do
      Fabricate.times(2, :contact, registrar: epp_user.registrar)
      Fabricate.times(2, :contact)

      get_with_auth '/repp/v1/contacts', {}, epp_user
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      expect(body['total_pages']).to eq(1)

      # TODO: Maybe there is a way not to convert from and to json again
      expect(body['contacts'].to_json).to eq(epp_user.registrar.contacts.to_json)
    end
  end
end
