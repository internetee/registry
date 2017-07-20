require 'rails_helper'

RSpec.describe 'EPP contact:update' do
  let(:request) { post '/epp/command/update', frame: request_xml }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>TEST</contact:id>
            <contact:chg>
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
            </contact:chg>
          </contact:update>
        </update>
        <extension>
          <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
            <eis:ident cc="US" type="org">test</eis:ident>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }

  before do
    sign_in_to_epp_area
  end

  context 'when :ident tag is given and a contact has been imported from legacy software' do
    let(:contact) { build(:contact, code: 'TEST', ident: nil, ident_type: nil, ident_country_code: nil) }

    specify do
      contact.save(validate: false)
      request
      expect(response).to have_code_of(2306)
    end
  end
end
