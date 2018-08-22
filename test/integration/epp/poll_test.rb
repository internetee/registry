require 'test_helper'

class EppPollTest < ApplicationIntegrationTest
  def test_return_first_message_when_queue_is_not_empty
    message = messages(:domain_deleted)

    request_xml =
      <<-XML
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
    assert_equal Time.zone.parse('2010-07-05').iso8601, response_xml.at_css('msgQ qDate').text
    assert_equal 'Your domain has been deleted', response_xml.at_css('msgQ msg').text
  end

  def test_no_messages_in_queue
    registrars(:bestnames).messages.delete_all(:delete_all)

    request_xml =
      <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML
    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    response_xml = Nokogiri::XML(response.body)

    assert_equal 1300.to_s, response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
  end

  def test_dequeue_message
    message = messages(:greeting)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="ack" msgID="#{message.id}"/>
        </command>
      </epp>
    XML

    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    message.reload
    response_xml = Nokogiri::XML(response.body)

    assert_not message.queued?
    assert_equal 1000.to_s, response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 1.to_s, response_xml.at_css('msgQ')[:count]
    assert_equal message.id.to_s, response_xml.at_css('msgQ')[:id]
  end

  def test_message_of_other_registrars_cannot_be_dequeued
    message = messages(:farewell)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="ack" msgID="#{message.id}"/>
        </command>
      </epp>
    XML
    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    response_xml = Nokogiri::XML(response.body)
    message.reload

    assert message.queued?
    assert_equal 2303.to_s, response_xml.at_css('result')[:code]
  end

  def test_message_not_found
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="ack" msgID="0"/>
        </command>
      </epp>
    XML
    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    response_xml = Nokogiri::XML(response.body)

    assert_equal 2303.to_s, response_xml.at_css('result')[:code]
  end
end