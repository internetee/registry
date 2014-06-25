require 'rails_helper'

describe 'EPP Session', epp: true do
  let(:server) { server = Epp::Server.new({server: 'localhost', tag: 'test', password: 'test'}) }

  context 'when not connected' do
    it 'greets client upon connection' do
      response = Nokogiri::XML(server.open_connection)
      expect(response.css('epp svID').text).to eq('EPP server (DSDng)')
      server.close_connection
    end
  end

  context 'when connected' do
    before(:each) { server.open_connection }
    after(:each) { server.close_connection }

    it 'does not log in with invalid user' do
      response = epp_request('login.xml')
      expect(response[:result_code]).to eq('2501')
      expect(response[:msg]).to eq('Authentication error; server closing connection')

      Fabricate(:epp_user, active: false)

      response = epp_request('login.xml')
      expect(response[:result_code]).to eq('2501')
    end

    it 'prohibits further actions unless logged in' do
      response = epp_request('create_domain.xml')
      expect(response[:result_code]).to eq('2002')
      expect(response[:msg]).to eq('You need to login first.')
    end

    context 'with valid user' do
      before(:each) { Fabricate(:epp_user) }

      it 'logs in epp user' do
        response = epp_request('login.xml')
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
      end

      it 'logs out epp user' do
        epp_request('login.xml')

        response = epp_request('logout.xml')
        expect(response[:result_code]).to eq('1500')
        expect(response[:msg]).to eq('Command completed successfully; ending session')
      end

      it 'does not log in twice' do
        epp_request('login.xml')

        response = epp_request('login.xml')
        expect(response[:result_code]).to eq('2002')
        expect(response[:msg]).to match(/Already logged in. Use/)
      end
    end
  end
end
