require 'rails_helper'

RSpec.describe 'EPP domain:transfer' do
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <transfer op="request">
          <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
            <domain:name>test.com</domain:name>
            <domain:authInfo>
              <domain:pw>98oiewslkfkd</domain:pw>
            </domain:authInfo>
          </domain:transfer>
        </transfer>
      </command>
    </epp>
  XML
  }

  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    sign_in_to_epp_area
  end

  context 'when domain is not discarded' do
    let!(:domain) { create(:domain, name: 'test.com') }

    it 'returns epp code of 1000' do
      post '/epp/command/transfer', frame: request_xml
      expect(response_code).to eq('1000'), "Expected EPP code of 1000, got #{response_code} (#{response_description})"
    end
  end

  context 'when domain is discarded' do
    let!(:domain) { create(:domain_discarded, name: 'test.com') }

    it 'returns epp code of 2105' do
      post '/epp/command/transfer', frame: request_xml
      expect(response_code).to eq('2105'), "Expected EPP code of 2105, got #{response_code} (#{response_description})"
    end
  end
end
