require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  subject(:request) { post '/epp/command/update', frame: request_xml }
  let!(:registrant) { create(:registrant, code: 'old-code') }
  let!(:domain) { create(:domain, name: 'test.com', registrant: registrant) }
  let!(:new_registrant) { create(:registrant, code: 'new-code') }

  before :example do
    sign_in_to_epp_area
  end

  context 'when registrant change confirmation is enabled' do
    before :example do
      Setting.request_confrimation_on_registrant_change_enabled = true
    end

    context 'when domain name is disputed' do
      let!(:dispute) { create(:dispute, domain_name: 'test.com', password: 'test') }

      context 'when password is valid' do
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

        specify do
          request
          expect(response).to have_code_of(1001)
        end

        it 'does not change registrant' do
          expect { request; domain.reload }.to_not change { domain.registrant_code }
        end

        it 'does not close dispute' do
          expect { request }.to_not change { Dispute.count }
        end
      end

      context 'when password is invalid' do
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
                  <eis:pw>invalid</eis:pw>
                </eis:reserved>
              </eis:extdata>
            </extension>
          </command>
        </epp>
        XML
        }

        specify do
          request
          expect(response).to have_code_of(2202)
        end

        it 'does not change registrant' do
          expect { request; domain.reload }.to_not change { domain.registrant_code }
        end

        it 'does not close dispute' do
          expect { request }.to_not change { Dispute.count }
        end
      end

      context 'when password is absent' do
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
              </eis:extdata>
            </extension>
          </command>
        </epp>
        XML
        }

        specify do
          request
          expect(response).to have_code_of(2003)
        end

        it 'does not change registrant' do
          expect { request; domain.reload }.to_not change { domain.registrant_code }
        end

        it 'does not close dispute' do
          expect { request }.to_not change { Dispute.count }
        end
      end
    end

    context 'when domain name is not disputed' do
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
    end
  end

  context 'when registrant change confirmation is disabled' do
    before :example do
      Setting.request_confrimation_on_registrant_change_enabled = false
    end

    context 'when domain name is disputed' do
      let!(:dispute) { create(:dispute, domain_name: 'test.com', password: 'test') }

      context 'when password is valid' do
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

        specify do
          request
          expect(response).to have_code_of(1000)
        end

        it 'changes registrant' do
          expect { request; domain.reload }.to change { domain.registrant_code }.from('old-code').to('new-code')
        end

        it 'closes dispute' do
          expect { request }.to change { Dispute.count }.from(1).to(0)
        end
      end

      context 'when password is invalid' do
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
                  <eis:pw>invalid</eis:pw>
                </eis:reserved>
              </eis:extdata>
            </extension>
          </command>
        </epp>
        XML
        }

        specify do
          request
          expect(response).to have_code_of(2202)
        end

        it 'does not change registrant' do
          expect { request; domain.reload }.to_not change { domain.registrant_code }
        end

        it 'does not close dispute' do
          expect { request }.to_not change { Dispute.count }
        end
      end

      context 'when password is absent' do
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
              </eis:extdata>
            </extension>
          </command>
        </epp>
        XML
        }

        specify do
          request
          expect(response).to have_code_of(2003)
        end

        it 'does not change registrant' do
          expect { request; domain.reload }.to_not change { domain.registrant_code }
        end

        it 'does not close dispute' do
          expect { request }.to_not change { Dispute.count }
        end
      end
    end

    context 'when domain name is not disputed' do
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
    end
  end
end
