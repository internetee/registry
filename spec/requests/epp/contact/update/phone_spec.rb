require 'rails_helper'
require_relative '../shared/phone'

RSpec.describe 'EPP contact:update' do
  let!(:contact) { create(:contact, code: 'TEST') }
  let(:request) { post '/epp/command/update', frame: request_xml }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>TEST</contact:id>
            <contact:chg>
              <contact:voice>#{phone}</contact:voice>
            </contact:chg>
          </contact:update>
        </update>
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
