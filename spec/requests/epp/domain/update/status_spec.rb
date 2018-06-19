require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user).session_id }
  let(:request) { post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
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
    sign_in user
  end

  context 'when domain has both SERVER_DELETE_PROHIBITED and PENDING_UPDATE statuses' do
    let!(:domain) { create(:domain,
                           name: 'test.com',
                           statuses: [DomainStatus::SERVER_DELETE_PROHIBITED,
                                      DomainStatus::PENDING_UPDATE])
    }

    it 'returns PENDING_UPDATE as domain status' do
      request
      status = Nokogiri::XML(response.body).at_xpath('//domain:status',
                                                     domain: 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').content
      expect(status).to eq(DomainStatus::PENDING_UPDATE)
    end
  end
end
