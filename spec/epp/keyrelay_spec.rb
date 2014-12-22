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
      expect(response[:msg]).to eq('Only one parameter allowed: relative or absolute')

      expect(zone.messages.queued.count).to eq(0)
    end
  end
end
