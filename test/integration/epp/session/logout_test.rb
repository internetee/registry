require 'test_helper'

class EppLogoutTest < ActionDispatch::IntegrationTest
  def setup
    @request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <logout/>
        </command>
      </epp>
    XML

    post '/epp/session/logout', { frame: @request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
  end

  def test_success_response
    assert Nokogiri::XML(response.body).at_css('result[code="1500"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_ends_current_session
    assert_nil EppSession.find_by(session_id: 'api_bestnames')
  end

  def test_keeps_other_sessions_intact
    assert EppSession.find_by(session_id: 'api_goodnames')
  end
end
