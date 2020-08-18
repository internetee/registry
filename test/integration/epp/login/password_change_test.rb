require 'test_helper'

class EppLoginPasswordChangeTest < EppTestCase
  def test_password_change
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <newPW>new-password</newPW>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML

    post epp_login_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=new_session_id' }
    assert_equal 'new-password', users(:api_bestnames).plain_text_password
    assert_epp_response :completed_successfully
  end
end