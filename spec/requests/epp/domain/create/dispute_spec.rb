require 'rails_helper'

RSpec.describe 'EPP domain:create' do
  subject(:request) { post '/epp/command/create', frame: request_xml }

  before :example do
    travel_to Time.zone.parse('05.07.2010')

    user = create(:api_user_with_unlimited_balance)

    create(:registrant, code: 'test')

    create(:pricelist,
           category: 'com',
           duration: '1year',
           price: 1.to_money,
           operation_category: 'create',
           valid_from: Time.zone.parse('05.07.2010'),
           valid_to: Time.zone.parse('05.07.2010')
    )

    sign_in_to_epp_area(user: user)
  end

  context 'when domain name is disputed' do
    let!(:dispute) { create(:dispute, domain_name: 'test.com', password: 'test') }

    context 'when password is valid' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:registrant>test</domain:registrant>
              </domain:create>
            </create>
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

      it 'creates domain' do
        expect { request }.to change { Domain.count }.from(0).to(1)
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
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:registrant>test</domain:registrant>
              </domain:create>
            </create>
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

      it 'does not create domain' do
        expect { request }.to_not change { Domain.count }
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
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:registrant>test</domain:registrant>
              </domain:create>
            </create>
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

      it 'does not close dispute' do
        expect { request }.to_not change { Dispute.count }
      end

      it 'does not create domain' do
        expect { request }.to_not change { Domain.count }
      end
    end
  end

  context 'when domain name is not disputed' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.com</domain:name>
              <domain:period unit="y">1</domain:period>
              <domain:registrant>test</domain:registrant>
            </domain:create>
          </create>
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

    it 'creates domain' do
      expect { request }.to change { Domain.count }.from(0).to(1)
    end
  end
end
