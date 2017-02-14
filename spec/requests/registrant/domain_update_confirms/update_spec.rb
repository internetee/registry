require 'rails_helper'

RSpec.describe 'domain_update_confirms update' do
  let!(:api_user) { create(:api_user, id: 1) }
  let!(:registrant) { create(:registrant, code: 'old-code') }
  let!(:domain) { create(:domain_with_pending_update,
                         registrant: registrant,
                         name: 'test.com',
                         registrant_verification_asked_at: Time.zone.parse('05.07.2010'),
                         registrant_verification_token: 'test',
                         pending_json: { frame: request_xml,
                                         current_user_id: 1,
                                         new_registrant_id: 1 })
  }
  let!(:new_registrant) { create(:registrant, code: 'new-code') }
  let!(:dispute) { create(:dispute, domain_name: 'test.com', password: 'test') }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
            <domain:name>test.com</domain:name>
              <domain:chg>
                <domain:registrant>new-code</domain:registrant>
              </domain:chg>
          </domain:update>
        </update>
        <extension>
          <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
            <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
            <eis:reserved>
              <eis:pw>test</eis:pw>
            </eis:reserved>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }
  subject(:request) { patch registrant_domain_update_confirm_path(domain),
                            confirmed: true,
                            token: 'test' }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
  end

  it 'closes dispute' do
    expect { request }.to change { Dispute.count }.from(1).to(0)
  end

  it 'redirects to :show' do
    request
    p controller.flash
    expect(response).to redirect_to registrant_domain_update_confirm_path(domain,
                                                                          confirmed: true)
  end
end
