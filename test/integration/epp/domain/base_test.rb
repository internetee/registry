require 'test_helper'

class EppDomainBaseTest < EppTestCase
  def test_non_existent_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>non-existent.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :object_does_not_exist
    assert_correct_against_schema response_xml
  end

  def test_invalid_path
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <info>
            <domain:info xmlns:domain="https://afdsfs.dfdf.df">
              <domain:name>non-existent.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :wrong_schema
  end
end
