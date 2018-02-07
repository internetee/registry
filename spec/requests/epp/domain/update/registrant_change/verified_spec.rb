require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
  let(:request) { post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let!(:registrant) { create(:registrant, code: 'old-code') }
  let!(:domain) { create(:domain, name: 'test.com', registrant: registrant) }
  let!(:new_registrant) { create(:registrant, code: 'new-code') }

  before :example do
    login_as user
  end

  context 'when registrant change confirmation is enabled' do
    before :example do
      Setting.request_confrimation_on_registrant_change_enabled = true
    end

    context 'when verified' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                  <domain:chg>
                    <domain:registrant verified="yes">new-code</domain:registrant>
                  </domain:chg>
              </domain:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      specify do
        request
        expect(response).to have_code_of(1000)
      end

      it 'changes registrant' do
        expect { request; domain.reload }.to change { domain.registrant_code }.from('old-code').to('new-code')
      end

      it 'does not send confirmation email' do
        expect { request }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'does not set PENDING_UPDATE status to domain' do
        request
        domain.reload
        expect(domain.statuses).to_not include(DomainStatus::PENDING_UPDATE)
      end
    end

    context 'when not verified' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                  <domain:chg>
                    <domain:registrant verified="no">new-code</domain:registrant>
                  </domain:chg>
              </domain:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      specify do
        request
        expect(response).to have_code_of(1001)
      end

      it 'does not change registrant' do
        expect { request; domain.reload }.to_not change { domain.registrant_code }
      end

      it 'sends confirmation and notice emails' do
        expect { request }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end

      it 'sets PENDING_UPDATE status to domain' do
        request
        domain.reload
        expect(domain.statuses).to include(DomainStatus::PENDING_UPDATE)
      end
    end
  end

  context 'when registrant change confirmation is disabled' do
    before :example do
      Setting.request_confrimation_on_registrant_change_enabled = false
    end

    context 'when verified' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                  <domain:chg>
                    <domain:registrant verified="yes">new-code</domain:registrant>
                  </domain:chg>
              </domain:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      specify do
        request
        expect(response).to have_code_of(1000)
      end

      it 'changes registrant' do
        expect { request; domain.reload }.to change { domain.registrant_code }.from('old-code').to('new-code')
      end

      it 'does not send confirmation email' do
        expect { request }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'does not set PENDING_UPDATE status to domain' do
        request
        domain.reload
        expect(domain.statuses).to_not include(DomainStatus::PENDING_UPDATE)
      end
    end

    context 'when not verified' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                  <domain:chg>
                    <domain:registrant verified="no">new-code</domain:registrant>
                  </domain:chg>
              </domain:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      specify do
        request
        expect(response).to have_code_of(1000)
      end

      it 'changes registrant' do
        expect { request; domain.reload }.to change { domain.registrant_code }.from('old-code').to('new-code')
      end

      it 'does not send confirmation email' do
        expect { request }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'does not set PENDING_UPDATE status to domain' do
        request
        domain.reload
        expect(domain.statuses).to_not include(DomainStatus::PENDING_UPDATE)
      end
    end
  end
end
