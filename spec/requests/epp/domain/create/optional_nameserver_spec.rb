require 'rails_helper'

RSpec.describe 'EPP domain:create' do
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    travel_to Time.zone.parse('05.07.2010')

    registrar = create(:registrar)
    user = create(:api_user_epp, registrar: registrar)
    create(:account, registrar: registrar, balance: 1.0)

    create(:contact, code: 'test')

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
                <domain:name>test.com</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:ns>
                  <domain:hostAttr>
                    <domain:hostName>ns.test.com</domain:hostName>
                  </domain:hostAttr>
                </domain:ns>
                <domain:registrant>test</domain:registrant>
                <domain:contact type="admin">test</domain:contact>
                <domain:contact type="tech">test</domain:contact>
              </domain:create>
            </create>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      before :example do
        Setting.ns_min_count = 2
      end

      it 'returns epp code of 2308' do
        post '/epp/command/create', frame: request_xml
        expect(response_code).to eq('2308')
      end

      it 'returns epp description' do
        post '/epp/command/create', frame: request_xml

        description = 'Data management policy violation;' \
        " Nameserver count must be between #{Setting.ns_min_count}-#{Setting.ns_max_count}" \
        ' for active domains [nameservers]'
        expect(response_description).to eq(description)
      end
    end

    context 'when nameserver is absent' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <create>
              <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:registrant>test</domain:registrant>
                <domain:contact type="admin">test</domain:contact>
                <domain:contact type="tech">test</domain:contact>
              </domain:create>
            </create>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'returns epp code of 1000' do
        post '/epp/command/create', frame: request_xml
        expect(response_code).to eq('1000'), "Expected EPP code of 1000, got #{response_code} (#{response_description})"
      end

      it 'creates new domain' do
        expect { post '/epp/command/create', frame: request_xml }.to change { Domain.count }.from(0).to(1)
      end

      describe 'new domain' do
        it 'has status of inactive' do
          post '/epp/command/create', frame: request_xml
          domain = Domain.find_by(name: 'test.com')
          expect(domain.statuses).to include(DomainStatus::INACTIVE)
        end
      end
    end
  end
end
