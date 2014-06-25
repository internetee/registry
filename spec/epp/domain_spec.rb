require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:server) { server = Epp::Server.new({server: 'localhost', tag: 'test', password: 'test'}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    it 'creates a domain' do
      response = epp_request('create_domain.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
    end

  end
end
