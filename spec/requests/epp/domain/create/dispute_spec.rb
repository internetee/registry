require 'rails_helper'

RSpec.describe 'EPP domain:create' do
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
    post '/epp/command/create', frame: request_xml
  end

  context 'when domain name is disputed' do
    let!(:dispute) { create(:dispute, domain: domain, password: 'test') }

    context 'when password is valid' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                  <domain:chg>
                    <domain:registrant>test</domain:registrant>
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

      specify { expect(response).to have_code_of(1001) }
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
                    <domain:registrant>test</domain:registrant>
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

      specify { expect(response).to have_code_of(2202) }
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
                    <domain:registrant>test</domain:registrant>
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

      specify { expect(response).to have_code_of(2003) }
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
              <domain:contact type="admin">test</domain:contact>
              <domain:contact type="tech">test</domain:contact>
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

    specify { expect(response).to have_code_of(1000) }
  end
end
