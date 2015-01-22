require 'rails_helper'

describe 'EPP Session', epp: true do
  let(:server_gitlab) { Epp::Server.new({ server: 'localhost', tag: 'gitlab', password: 'ghyt9e4fu', port: 701 }) }
  let(:epp_xml) { EppXml.new(cl_trid: 'ABC-12345') }
  let(:login_xml_cache) { epp_xml.session.login(clID: { value: 'gitlab' }, pw: { value: 'ghyt9e4fu' }) }

  context 'when not connected' do
    it 'greets client upon connection' do
      response = Nokogiri::XML(server_gitlab.open_connection)
      expect(response.css('epp svID').text).to eq('EPP server (EIS)')
      server_gitlab.close_connection

      puts "RESPONSE:\n\n```xml\n#{response}```\n\n" if ENV['EPP_DOC']
    end
  end

  context 'when connected' do
    before(:each) { server_gitlab.open_connection }
    after(:each) { server_gitlab.close_connection }

    context 'with valid user' do
      before(:each) { Fabricate(:epp_user) }

      it 'logs in epp user' do
        response = epp_plain_request(login_xml_cache, :xml)
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(response[:clTRID]).to eq('ABC-12345')
      end

      it 'logs out epp user' do
        epp_plain_request(login_xml_cache, :xml)

        expect(EppSession.first[:epp_user_id]).to eq(1)
        response = epp_plain_request(epp_xml.session.logout, :xml)
        expect(response[:result_code]).to eq('1500')
        expect(response[:msg]).to eq('Command completed successfully; ending session')

        expect(EppSession.first[:epp_user_id]).to eq(nil)
      end

      it 'does not log in twice' do
        epp_plain_request(login_xml_cache, :xml)

        response = epp_plain_request(login_xml_cache, :xml)
        expect(response[:result_code]).to eq('2002')
        expect(response[:msg]).to match(/Already logged in. Use/)

        log = ApiLog::EppLog.all
        expect(log.length).to eq(3)
        expect(log[0].request_command).to eq('hello')
        expect(log[0].request_successful).to eq(true)

        expect(log[1].request_command).to eq('login')
        expect(log[1].request_successful).to eq(true)
        expect(log[1].api_user_name).to eq('gitlab')
        expect(log[1].api_user_registrar).to eq('Registrar OÜ')

        expect(log[2].request_command).to eq('login')
        expect(log[2].request_successful).to eq(false)
        expect(log[2].api_user_name).to eq('gitlab')
        expect(log[2].api_user_registrar).to eq('Registrar OÜ')
      end
    end

    it 'does not log in with invalid user' do
      response = epp_plain_request(login_xml_cache, :xml)
      expect(response[:result_code]).to eq('2501')
      expect(response[:msg]).to eq('Authentication error; server closing connection')
      expect(response[:clTRID]).to eq('ABC-12345')

      Fabricate(:epp_user, active: false)

      response = epp_plain_request(login_xml_cache, :xml)
      expect(response[:result_code]).to eq('2501')
    end

    it 'prohibits further actions unless logged in' do
      response = epp_plain_request(epp_xml.domain.create, :xml)
      expect(response[:result_code]).to eq('2002')
      expect(response[:msg]).to eq('You need to login first.')
      expect(response[:clTRID]).to eq('ABC-12345')
    end
  end
end
