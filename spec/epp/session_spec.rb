require 'rails_helper'

describe 'EPP Session', type: :epp do
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

    it 'logs in epp user' do
      response = Nokogiri::XML(server.send_request(read_body('login.xml')))
      result = response.css('epp response result').first
      expect(result[:code]).to eq('1000')

      msg = response.css('epp response result msg').text
      expect(msg).to eq('User test was authenticated. Welcome.')
    end
  end
end
