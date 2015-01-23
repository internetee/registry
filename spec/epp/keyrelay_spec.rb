require 'rails_helper'

describe 'EPP Keyrelay', epp: true do
  let(:server_zone) { Epp::Server.new({ server: 'localhost', tag: 'zone', password: 'ghyt9e4fu', port: 701 }) }
  let(:server_elkdata) { Epp::Server.new({ server: 'localhost', tag: 'elkdata', password: 'ghyt9e4fu', port: 701 }) }
  let(:elkdata) { Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' }) }
  let(:zone) { Fabricate(:registrar) }
  let(:domain) { Fabricate(:domain, name: 'example.ee', registrar: zone, dnskeys: [Fabricate.build(:dnskey)]) }
  let(:epp_xml) { EppXml::Keyrelay.new }

  before(:each) { create_settings }

  context 'with valid user' do
    before(:each) do
      Fabricate(:epp_user, username: 'zone', registrar: zone)
      Fabricate(:epp_user, username: 'elkdata', registrar: elkdata)
    end

    it 'makes a keyrelay request' do
      xml = epp_xml.keyrelay({
        name: { value: 'example.ee' },
        keyData: {
          flags: { value: '256' },
          protocol: { value: '3' },
          alg: { value: '8' },
          pubKey: { value: 'cmlraXN0aGViZXN0' }
        },
        authInfo: {
          pw: { value: domain.auth_info }
        },
        expiry: {
          relative: { value: 'P1M13D' }
        }
      })

      response = epp_request(xml, :xml, :elkdata)

      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:result_code]).to eq('1000')

      expect(zone.messages.queued.count).to eq(1)

      log = ApiLog::EppLog.all

      expect(log.length).to eq(4)
      expect(log[0].request_command).to eq('hello')
      expect(log[0].request_successful).to eq(true)

      expect(log[1].request_command).to eq('login')
      expect(log[1].request_successful).to eq(true)
      expect(log[1].api_user_name).to eq('elkdata')
      expect(log[1].api_user_registrar).to eq('Elkdata')

      expect(log[2].request_command).to eq('keyrelay')
      expect(log[2].request_object).to eq('keyrelay')
      expect(log[2].request_successful).to eq(true)
      expect(log[2].api_user_name).to eq('elkdata')
      expect(log[2].api_user_registrar).to eq('Elkdata')
      expect(log[2].request).not_to be_blank
      expect(log[2].response).not_to be_blank

      expect(log[3].request_command).to eq('logout')
      expect(log[3].request_successful).to eq(true)
      expect(log[3].api_user_name).to eq('elkdata')
      expect(log[3].api_user_registrar).to eq('Elkdata')
    end

    it 'returns an error when parameters are missing' do
      xml = epp_xml.keyrelay({
        name: { value: 'example.ee' },
        keyData: {
          flags: { value: '' },
          protocol: { value: '3' },
          alg: { value: '8' },
          pubKey: { value: 'cmlraXN0aGViZXN0' }
        },
        authInfo: {
          pw: { value: domain.auth_info }
        },
        expiry: {
          relative: { value: 'Invalid Expiry' }
        }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Required parameter missing: flags')

      expect(zone.messages.queued.count).to eq(0)
    end

    it 'returns an error on invalid relative expiry' do
      xml = epp_xml.keyrelay({
        name: { value: 'example.ee' },
        keyData: {
          flags: { value: '256' },
          protocol: { value: '3' },
          alg: { value: '8' },
          pubKey: { value: 'cmlraXN0aGViZXN0' }
        },
        authInfo: {
          pw: { value: domain.auth_info }
        },
        expiry: {
          relative: { value: 'Invalid Expiry' }
        }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Expiry relative must be compatible to ISO 8601')
      expect(response[:results][0][:value]).to eq('Invalid Expiry')

      expect(zone.messages.queued.count).to eq(0)
    end

    it 'returns an error on invalid absolute expiry' do
      xml = epp_xml.keyrelay({
        name: { value: 'example.ee' },
        keyData: {
          flags: { value: '256' },
          protocol: { value: '3' },
          alg: { value: '8' },
          pubKey: { value: 'cmlraXN0aGViZXN0' }
        },
        authInfo: {
          pw: { value: domain.auth_info }
        },
        expiry: {
          absolute: { value: 'Invalid Absolute' }
        }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Expiry absolute must be compatible to ISO 8601')
      expect(response[:results][0][:value]).to eq('Invalid Absolute')

      expect(zone.messages.queued.count).to eq(0)
    end

    it 'does not allow both relative and absolute' do
      xml = epp_xml.keyrelay({
        name: { value: 'example.ee' },
        keyData: {
          flags: { value: '256' },
          protocol: { value: '3' },
          alg: { value: '8' },
          pubKey: { value: 'cmlraXN0aGViZXN0' }
        },
        authInfo: {
          pw: { value: domain.auth_info }
        },
        expiry: {
          relative: { value: 'P1D' },
          absolute: { value: '2014-12-23' }
        }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Exactly one parameter required: expiry > relative or expiry > absolute')

      expect(zone.messages.queued.count).to eq(0)
    end
  end
end
