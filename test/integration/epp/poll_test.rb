require 'test_helper'

class EppPollTest < ApplicationIntegrationTest
  # Deliberately does not conform to RFC5730, which requires the first message to be returned
  def test_return_latest_message_when_queue_is_not_empty
    message = messages(:domain_deleted)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML
    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    response_xml = Nokogiri::XML(response.body)

    assert_equal 1301.to_s, response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 2.to_s, response_xml.at_css('msgQ')[:count]
    assert_equal message.id.to_s, response_xml.at_css('msgQ')[:id]
    assert_equal Time.zone.parse('2010-07-05').utc.xmlschema, response_xml.at_css('msgQ qDate').text
    assert_equal 'Your domain has been deleted', response_xml.at_css('msgQ msg').text
  end

  def test_no_messages
    registrars(:bestnames).messages.delete_all(:delete_all)
    post '/epp/command/poll', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_equal '1300', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML
  end
end
