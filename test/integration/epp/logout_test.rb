require 'test_helper'

class EppLogoutTest < EppTestCase
  def test_success_response
    post '/epp/session/logout', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_epp_response :completed_successfully_ending_session
  end

  def test_ends_current_session
    post '/epp/session/logout', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_nil EppSession.find_by(session_id: 'api_bestnames')
  end

  def test_keeps_other_sessions_intact
    post '/epp/session/logout', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert EppSession.find_by(session_id: 'api_goodnames')
  end

  def test_anonymous_user
    post '/epp/session/logout', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=non-existent' }
    assert_epp_response :authorization_error
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <logout/>
        </command>
      </epp>
    XML
  end
end
