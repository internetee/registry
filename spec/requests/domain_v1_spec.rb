require 'rails_helper'

describe Repp::DomainV1 do
  let(:epp_user) { Fabricate(:epp_user) }

  before(:each) { create_settings }

  describe 'GET /repp/v1/domains' do
    it 'returns domains of the current registrar' do
      Fabricate.times(2, :domain, registrar: epp_user.registrar)

      get_with_auth '/repp/v1/domains', {}, epp_user
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      expect(body['total_pages']).to eq(1)

      # TODO: Maybe there is a way not to convert from and to json again
      expect(body['domains'].to_json).to eq(epp_user.registrar.domains.to_json)
    end
  end
end
