require 'application_system_test_case'

class RegistrarAreaXmlConsolesTest < ApplicationSystemTestCase

  setup do
    sign_in users(:api_bestnames)
  end

#   CodeRay

  def test_epp_server_does_not_response
	visit registrar_xml_console_path
	fill_in 'payload', with: schema_example
	click_on 'Send EPP Request'

	el = page.find('.CodeRay', visible: :all)
	assert el.text.include? 'CONNECTION ERROR - Is the EPP server running?'
  end

  private

  def schema_example
    request_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML
  end

end