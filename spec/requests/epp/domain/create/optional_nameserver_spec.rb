require 'rails_helper'

RSpec.describe 'EPP domain:create', settings: false do
  let(:request) { post '/epp/command/create', frame: request_xml }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:contact) { create(:contact, code: 'test') }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:price) { create(:price,
                        duration: '1 year',
                        price: Money.from_amount(1),
                        operation_category: 'create',
                        valid_from: Time.zone.parse('05.07.2010'),
                        valid_to: Time.zone.parse('05.07.2010'),
                        zone: zone)
  }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_epp_area(user: user)
  end

  context 'when nameserver is optional' do
    before :example do
      allow(Domain).to receive(:nameserver_required?).and_return(false)
    end

    context 'when minimum nameserver count requirement is not satisfied' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.test</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:ns>
                  <domain:hostAttr>
                    <domain:hostName>ns.test.com</domain:hostName>
                    <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
                  </domain:hostAttr>
                </domain:ns>
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

      before :example do
        Setting.ns_min_count = 2
      end

      it 'does not create domain' do
        expect { request }.to_not change { Domain.count }
      end

      specify do
        request
        expect(response).to have_code_of(2308)
      end
    end

    context 'when nameserver is absent' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.test</domain:name>
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

      it 'creates new domain' do
        expect { request }.to change { Domain.count }.from(0).to(1)
      end

      describe 'new domain' do
        it 'has status of inactive' do
          request
          expect(Domain.first.statuses).to include(DomainStatus::INACTIVE)
        end
      end

      specify do
        request
        expect(response).to have_code_of(1000)
      end
    end
  end
end
