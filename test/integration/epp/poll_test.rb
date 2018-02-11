require 'test_helper'

class EppPollTest < ActionDispatch::IntegrationTest
  def setup
    @session_id = epp_sessions(:api_bestnames).session_id
  end

  def test_messages
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML

    post '/epp/command/poll', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{@session_id}" }
    assert Nokogiri::XML(response.body).at_css('result[code="1301"]')
    assert_equal 1, Nokogiri::XML(response.body).css('msgQ').size
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_no_messages
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML

    Message.delete_all
    post '/epp/command/poll', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{@session_id}" }
    assert Nokogiri::XML(response.body).at_css('result[code="1300"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_unauthenticated_user
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML

    post '/epp/command/poll', frame: request_xml
    assert Nokogiri::XML(response.body).at_css('result[code="2201"]')
  end
end
