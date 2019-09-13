require 'test_helper'

class EppLoginTest < EppTestCase
  def test_correct_credentials
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML
    post '/epp/session/login', { frame: request_xml }, 'HTTP_COOKIE' => 'session=new_session_id'

    assert_epp_response :completed_successfully
    assert EppSession.find_by(session_id: 'new_session_id')
    assert_equal users(:api_bestnames), EppSession.find_by(session_id: 'new_session_id').user
  end

  def test_user_cannot_login_again
    session = epp_sessions(:api_bestnames)
    user = session.user

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>#{user.username}</clID>
            <pw>#{user.plain_text_password}</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML
    post '/epp/session/login', { frame: request_xml }, HTTP_COOKIE: "session=#{session.session_id}"

    assert_epp_response :use_error
  end

  def test_wrong_credentials
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>non-existent</clID>
            <pw>valid-but-wrong</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML
    post '/epp/session/login', { frame: request_xml }, 'HTTP_COOKIE' => 'session=any_random_string'

    assert_epp_response :authentication_error_server_closing_connection
  end

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
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML
    post '/epp/session/login', { frame: request_xml }, 'HTTP_COOKIE' => 'session=new_session_id'

    assert_equal 'new-password', users(:api_bestnames).plain_text_password
    assert_epp_response :completed_successfully
  end

  def test_not_reached
    travel_to Time.zone.parse('2010-07-05')
    EppSession.delete_all
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML

    (EppSession.limit_per_registrar - 1).times do
      EppSession.create!(session_id: SecureRandom.hex,
                         user: users(:api_bestnames),
                         updated_at: Time.zone.parse('2010-07-05'))
    end

    assert_difference 'EppSession.count' do
      post '/epp/session/login', { frame: request_xml }, 'HTTP_COOKIE' => 'session=new_session_id'
    end
    assert_epp_response :completed_successfully
  end

  def test_reached
    travel_to Time.zone.parse('2010-07-05')
    EppSession.delete_all
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML

    EppSession.limit_per_registrar.times do
      EppSession.create!(session_id: SecureRandom.hex,
                         user: users(:api_bestnames),
                         updated_at: Time.zone.parse('2010-07-05'))
    end

    assert_no_difference 'EppSession.count' do
      post '/epp/session/login', { frame: request_xml }, 'HTTP_COOKIE' => 'session=new_session_id'
    end
    assert_epp_response :authentication_error_server_closing_connection
  end
end
