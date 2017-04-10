require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  subject(:request) { post '/epp/command/update', frame: request_xml }
  let!(:domain) { create(:domain, name: 'test.com') }

  before :example do
    sign_in_to_epp_area
  end

  context 'when domain name is disputed' do
    let!(:dispute) { create(:dispute, domain_name: 'test.com') }

    context 'when password is absent' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
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
    end
  end
end
