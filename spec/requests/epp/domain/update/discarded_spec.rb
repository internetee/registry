require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
            <domain:name>test.com</domain:name>
          </domain:update>
        </update>
      </command>
    </epp>
  XML
  }

  before :example do
    sign_in_to_epp_area
  end

  context 'when domain is not discarded' do
    let!(:domain) { create(:domain, name: 'test.com') }

    it 'returns epp code of 1000' do
      post '/epp/command/update', frame: request_xml
      expect(response).to have_code_of(1000)
    end
  end

  context 'when domain is discarded' do
    let!(:domain) { create(:domain_discarded, name: 'test.com') }

    it 'returns epp code of 2105' do
      post '/epp/command/update', frame: request_xml
      expect(response).to have_code_of(2105)
    end
  end
end
