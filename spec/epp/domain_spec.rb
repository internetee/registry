require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:server) { server = Epp::Server.new({server: 'localhost', tag: 'test', password: 'test'}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    it 'creates a domain' do
      response = epp_request('create_domain.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('dpbx005#10-01-29at19:21:47')
      expect(Domain.first.registrar.name).to eq('Zone Media OÜ')
    end

  end
end
