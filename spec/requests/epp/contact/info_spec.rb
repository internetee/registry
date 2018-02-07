require 'rails_helper'

RSpec.describe 'EPP contact:update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
  let(:request_xml) { '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <info>
          <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>test</contact:id>
          </contact:info>
        </info>
      </command>
    </epp>'
  }
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:address_count) { response_xml
                              .xpath('//contact:addr', contact: 'https://epp.tld.ee/schema/contact-ee-1.1.xsd')
                              .count }

  before do
    login_as user
    create(:contact, code: 'TEST')
  end

  context 'when address processing is enabled' do
    before do
      allow(Contact).to receive(:address_processing?).and_return(true)
    end

    it 'returns epp code of 1000' do
      post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('1000')
    end

    it 'returns address' do
      post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(address_count).to_not be_zero
    end
  end

  context 'when address processing is disabled' do
    before do
      allow(Contact).to receive(:address_processing?).and_return(false)
    end

    it 'returns epp code of 1000' do
      post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('1000')
    end

    it 'does not return address' do
      post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(address_count).to be_zero
    end
  end
end
