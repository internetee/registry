require 'rails_helper'

describe 'EPP Contact', epp: true do
  let(:server) { Epp::Server.new({server: 'localhost', tag: 'test', password: 'test', port: 701}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    # incomplete
    it 'creates a contact' do
      response = epp_request('contacts/create.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('ABC-12345')
    end

  end
end
