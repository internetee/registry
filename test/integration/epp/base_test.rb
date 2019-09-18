require 'test_helper'

class EppBaseTest < EppTestCase
  setup do
    @original_session_timeout = EppSession.timeout
  end

  teardown do
    EppSession.timeout = @original_session_timeout
  end

  def test_deletes_session_when_timed_out
    now = Time.zone.parse('2010-07-05')
    travel_to now
    timeout = 0.second
    EppSession.timeout = timeout
    session = epp_sessions(:api_bestnames)
    session.update!(updated_at: now - timeout - 1.second)

    authentication_enabled_epp_request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post '/epp/command/info', { frame: authentication_enabled_epp_request_xml },
         'HTTP_COOKIE' => "session=#{session.session_id}"

    assert_epp_response :authorization_error
    assert_nil EppSession.find_by(session_id: session.session_id)
  end

  def test_session_last_access_is_updated_when_not_timed_out
    now = Time.zone.parse('2010-07-05')
    travel_to now
    timeout = 1.seconds
    EppSession.timeout = timeout
    session = epp_sessions(:api_bestnames)
    session.last_access = now - timeout

    authentication_enabled_epp_request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: authentication_enabled_epp_request_xml },
         'HTTP_COOKIE' => "session=#{session.session_id}"
    session.reload

    assert_epp_response :completed_successfully
    assert_equal now, session.last_access
  end
end
