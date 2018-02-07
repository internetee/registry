require 'rails_helper'

RSpec.describe 'EPP domain:transfer' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
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

  before :example do
    login_as user
  end

  context 'when domain is not discarded' do
    let!(:domain) { create(:domain, name: 'test.com') }

    it 'returns epp code of 1000' do
      post '/epp/command/transfer', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response).to have_code_of(1000)
    end
  end

  context 'when domain is discarded' do
    let!(:domain) { create(:domain_discarded, name: 'test.com') }

    it 'returns epp code of 2105' do
      post '/epp/command/transfer', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response).to have_code_of(2105)
    end
  end
end
