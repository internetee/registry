require 'rails_helper'
require_relative '../shared/phone'

RSpec.describe 'EPP contact:create' do
  let(:request) { post '/epp/command/create', frame: request_xml }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <create>
          <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:postalInfo>
              <contact:name>test</contact:name>
            </contact:postalInfo>
            <contact:voice>#{phone}</contact:voice>
            <contact:email>test@test.com</contact:email>
          </contact:create>
        </create>
        <extension>
          <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
            <eis:ident type="org" cc="US">123456</eis:ident>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }

  before do
    sign_in_to_epp_area
    allow(Contact).to receive(:address_processing?).and_return(false)
  end

  include_examples 'EPP contact phone'
end
