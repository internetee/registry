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

    it 'does not log in with invalid user' do
      response = Nokogiri::XML(server.send_request(read_body('login.xml')))
      result = response.css('epp response result').first
      expect(result[:code]).to eq('2501')

      msg = response.css('epp response result msg').text
      expect(msg).to eq('Authentication error; server closing connection')

      Fabricate(:epp_user, active: false)

      response = Nokogiri::XML(server.send_request(read_body('login.xml')))
      result = response.css('epp response result').first
      expect(result[:code]).to eq('2501')
    end

    it 'logs in epp user' do
      Fabricate(:epp_user)

      response = Nokogiri::XML(server.send_request(read_body('login.xml')))

      result = response.css('epp response result').first
      expect(result[:code]).to eq('1000')

      msg = response.css('epp response result msg').text
      expect(msg).to eq('Command completed successfully')
    end

    it 'does not log in twice' do
      Fabricate(:epp_user)
      server.send_request(read_body('login.xml'))
      response = Nokogiri::XML(server.send_request(read_body('login.xml')))

      result = response.css('epp response result').first
      expect(result[:code]).to eq('2002')

      msg = response.css('epp response result msg').text
      expect(msg).to match(/Already logged in. Use/)
    end
  end
end
