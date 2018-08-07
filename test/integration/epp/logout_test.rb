require 'test_helper'

class EppLogoutTest < ApplicationIntegrationTest
  def test_success_response
    post '/epp/session/logout', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert Nokogiri::XML(response.body).at_css('result[code="1500"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
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
    assert Nokogiri::XML(response.body).at_css('result[code="2201"]')
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
