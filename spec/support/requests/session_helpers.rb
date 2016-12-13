module Requests
  module SessionHelpers
    def sign_in_to_epp_area(user: FactoryGirl.create(:api_user))
      login_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
      <epp xmlns=\"urn:ietf:params:xml:ns:epp-1.0\">
        <command>
          <login>
            <clID>#{user.username}</clID>
            <pw>#{user.password}</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
              <svcExtension>
                <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
                <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
              </svcExtension>
            </svcs>
          </login>
          <clTRID>ABC-12345</clTRID>
        </command>
      </epp>"

      post '/epp/session/login', frame: login_xml
    end
  end
end
