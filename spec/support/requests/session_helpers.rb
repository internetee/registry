module Requests
  module SessionHelpers
    def sign_in_to_epp_area(user: FactoryGirl.create(:api_user_epp))
      login_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
      <epp xmlns=\"https://epp.tld.ee/schema/epp-ee-1.0.xsd\">
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
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
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

    def sign_in_to_admin_area(user: FactoryGirl.create(:admin_user))
      post admin_sessions_path, admin_user: { username: user.username, password: user.password }
    end

    def sign_in_to_registrar_area(user: FactoryGirl.create(:api_user))
      post registrar_sessions_path, { depp_user: { tag: user.username, password: user.password } }
    end
  end
end
