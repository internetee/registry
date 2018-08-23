require 'test_helper'

class EppPollTest < ApplicationIntegrationTest
  # Deliberately does not conform to RFC5730, which requires the first message to be returned
  def test_return_latest_notification_when_queue_is_not_empty
    notification = notifications(:domain_deleted)

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
    assert_equal notification.id.to_s, response_xml.at_css('msgQ')[:id]
    assert_equal Time.zone.parse('2010-07-05').iso8601, response_xml.at_css('msgQ qDate').text
    assert_equal 'Your domain has been deleted', response_xml.at_css('msgQ msg').text
  end

  def test_no_notifications
    registrars(:bestnames).notifications.delete_all(:delete_all)

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

  def test_dequeue_notification
    notification = notifications(:greeting)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="ack" msgID="#{notification.id}"/>
        </command>
      </epp>
    XML

    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    notification.reload
    response_xml = Nokogiri::XML(response.body)

    assert_not notification.queued?
    assert_equal 1000.to_s, response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 1.to_s, response_xml.at_css('msgQ')[:count]
    assert_equal notification.id.to_s, response_xml.at_css('msgQ')[:id]
  end

  def test_notification_of_other_registrars_cannot_be_dequeued
    notification = notifications(:farewell)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="ack" msgID="#{notification.id}"/>
        </command>
      </epp>
    XML
    post '/epp/command/poll', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    response_xml = Nokogiri::XML(response.body)
    notification.reload

    assert notification.queued?
    assert_equal 2303.to_s, response_xml.at_css('result')[:code]
  end

  def test_notification_not_found
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