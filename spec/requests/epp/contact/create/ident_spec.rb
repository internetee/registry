require 'rails_helper'

RSpec.describe 'EPP contact:create' do
  let(:request) { post '/epp/command/create', frame: request_xml }

  before do
    Setting.address_processing = false
    sign_in_to_epp_area
  end

  context 'when all ident params are valid' do
    let(:ident) { Contact.first.identifier }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">test</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    it 'creates a contact' do
      expect { request }.to change { Contact.count }.from(0).to(1)
    end

    it 'saves ident type' do
      request
      expect(ident.type).to eq('priv')
    end

    it 'saves ident country code' do
      request
      expect(ident.country_code).to eq('US')
    end

    specify do
      request
      expect(epp_response).to have_result(:success)
    end
  end

  context 'when code is blank' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US"></eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request
      expect(epp_response).to have_result(:required_param_missing,
                                          'Required parameter missing: extension > extdata > ident [ident]')
    end
  end

  context 'when code is not valid national id' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="DE">invalid</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    before do
      country_specific_validations = {
        Country.new('DE') => proc { false },
      }

      allow(Contact::Ident::NationalIDValidator).to receive(:country_specific_validations)
                                                      .and_return(country_specific_validations)
    end

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request

      message = 'Ident code does not conform to national identification number format of Germany'
      expect(epp_response).to have_result(:param_syntax_error, message)
    end
  end

  context 'when code is not valid registration number' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="org" cc="DE">invalid</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    before do
      country_specific_formats = {
        Country.new('DE') => /\Avalid\z/,
      }

      allow(Contact::Ident::RegNoValidator).to receive(:country_specific_formats).and_return(country_specific_formats)
    end

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request
      expect(epp_response).to have_result(:param_syntax_error,
                                          'Ident code does not conform to registration number format of Germany')
    end
  end

  context 'when country code is absent' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv">test</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request
      expect(epp_response).to have_result(:required_param_missing,
                                          'Required ident attribute missing: cc')
    end
  end

  context 'when country code is blank' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="">test</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request
      expect(epp_response).to have_result(:syntax_error)
    end
  end

  context 'when mismatches' do
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>test@test.com</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="DE">test</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    }

    before do
      mismatches = [
        Contact::Ident::MismatchValidator::Mismatch.new('priv', Country.new('DE'))
      ]
      allow(Contact::Ident::MismatchValidator).to receive(:mismatches).and_return(mismatches)
    end

    it 'does not create a contact' do
      expect { request }.to_not change { Contact.count }
    end

    specify do
      request
      expect(epp_response).to have_result(:param_syntax_error,
                                          'Ident type "priv" is invalid for Germany')
    end
  end
end
