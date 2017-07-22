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
            <eis:ident cc="GB" type="priv">test</eis:ident>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }

  before do
    sign_in_to_epp_area
  end

  context 'when submitted ident matches current one' do
    let!(:contact) { create(:contact, code: 'TEST', ident: 'test', ident_type: 'org', ident_country_code: 'US') }

    it 'updates :ident_type' do
      request
      contact.reload
      expect(contact.ident_type).to eq('priv')
    end

    it 'updates :ident_country_code' do
      request
      contact.reload
      expect(contact.ident_country_code).to eq('GB')
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end

  context 'when submitted ident does not match current one' do
    let!(:contact) { create(:contact, code: 'TEST', ident: 'some-ident', ident_type: 'org', ident_country_code: 'US') }

    it 'does not update :ident_type' do
      request
      contact.reload
      expect(contact.ident_type).to eq('org')
    end

    it 'does not update :ident_country_code' do
      request
      contact.reload
      expect(contact.ident_country_code).to eq('US')
    end

    specify do
      request
      expect(response).to have_code_of(2308)
    end
  end
end
