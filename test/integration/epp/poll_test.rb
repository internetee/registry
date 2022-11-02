require 'test_helper'

class EppPollTest < EppTestCase
  setup do
    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
    @notification = notifications(:complete)
  end

  # Deliberately does not conform to RFC5730, which requires the first notification to be returned
  def test_return_latest_notification_when_queue_is_not_empty
    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    xml_doc = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully_ack_to_dequeue
    assert_equal 2.to_s, xml_doc.at_css('msgQ')[:count]
    assert_equal @notification.id.to_s, xml_doc.at_css('msgQ')[:id]
    assert_equal Time.zone.parse('2010-07-05').utc.xmlschema, xml_doc.at_css('msgQ qDate').text
    assert_equal 'Your domain has been updated', xml_doc.at_css('msgQ msg').text
  end

  def test_does_not_drop_error_if_old_version
    version = Version::DomainVersion.last
    @notification.update(attached_obj_type: 'DomainVersion', attached_obj_id: version.id)

    assert_nothing_raised do
      post epp_poll_path, params: { frame: request_req_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    xml_doc = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully_ack_to_dequeue
    assert_equal 2.to_s, xml_doc.at_css('msgQ')[:count]
    assert_equal @notification.id.to_s, xml_doc.at_css('msgQ')[:id]
    assert_equal Time.zone.parse('2010-07-05').utc.xmlschema, xml_doc.at_css('msgQ qDate').text
    assert_equal 'Your domain has been updated', xml_doc.at_css('msgQ msg').text
  end

  def test_return_action_data_when_present
    @notification.update!(action: actions(:contact_update))

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    xml_doc = Nokogiri::XML(response.body)
    namespace = Xsd::Schema.filename(for_prefix: 'changePoll', for_version: '1.0')
    assert_equal 'update', xml_doc.xpath('//changePoll:operation', 'changePoll' => namespace).text
    assert_equal Time.zone.parse('2010-07-05').utc.xmlschema,
                 xml_doc.xpath('//changePoll:date', 'changePoll' => namespace).text
    assert_equal @notification.action.id.to_s, xml_doc.xpath('//changePoll:svTRID',
                                                             'changePoll' => namespace).text
    assert_equal 'Registrant User', xml_doc.xpath('//changePoll:who',
                                                  'changePoll' => namespace).text
  end

  def test_return_notifcation_with_bulk_action_data
    bulk_action = actions(:contacts_update_bulk_action)
    @notification.update!(action: bulk_action,
                          attached_obj_id: bulk_action.id,
                          attached_obj_type: 'ContactUpdateAction')

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    xml_doc = Nokogiri::XML(response.body)
    namespace = Xsd::Schema.filename(for_prefix: 'changePoll', for_version: '1.0')

    assert_equal 2, xml_doc.xpath('//contact:cd', contact: xml_schema).size
    assert_epp_response :completed_successfully_ack_to_dequeue
    assert_equal 'bulk_update', xml_doc.xpath('//changePoll:operation',
                                              'changePoll' => namespace).text
    assert_equal @notification.action.id.to_s, xml_doc.xpath('//changePoll:svTRID',
                                                             'changePoll' => namespace).text
    assert_equal 'Registrant User', xml_doc.xpath('//changePoll:who',
                                                  'changePoll' => namespace).text
    assert_equal 'Auto-update according to official data',
                 xml_doc.xpath('//changePoll:reason', 'changePoll' => namespace).text
  end

  def test_no_notifications
    registrars(:bestnames).notifications.delete_all(:delete_all)

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully_no_messages
  end

  def test_mark_as_read
    notification = notifications(:greeting)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <poll op="ack" msgID="#{notification.id}"/>
        </command>
      </epp>
    XML

    post epp_poll_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    notification.reload

    xml_doc = Nokogiri::XML(response.body)
    assert notification.read?
    assert_epp_response :completed_successfully
    assert_equal 1.to_s, xml_doc.at_css('msgQ')[:count]
    assert_equal notification.id.to_s, xml_doc.at_css('msgQ')[:id]
  end

  def test_notification_of_other_registrars_cannot_be_marked_as_read
    notification = notifications(:farewell)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <poll op="ack" msgID="#{notification.id}"/>
        </command>
      </epp>
    XML
    post epp_poll_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    notification.reload

    assert notification.unread?
    assert_epp_response :object_does_not_exist
  end

  def test_notification_not_found
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <poll op="ack" msgID="0"/>
        </command>
      </epp>
    XML
    post epp_poll_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :object_does_not_exist
  end

  def test_anonymous_user_cannot_access
    post '/epp/command/poll', params: { frame: request_req_xml },
                              headers: { 'HTTP_COOKIE' => 'session=non-existent' }

    assert_epp_response :authorization_error
  end

  def test_returns_valid_response_if_not_throttled
    notification = notifications(:greeting)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <poll op="ack" msgID="#{notification.id}"/>
        </command>
      </epp>
    XML

    post epp_poll_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :session_limit_exceeded_server_closing_connection
    assert_correct_against_schema response_xml
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end

  def test_returns_error_response_if_throttled_with_configurated_rate_limit
    ENV['shunter_enabled'] = 'true'
    user = registrars(:bestnames)
    user.update(rate_limit: 1)
    user.reload

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    post epp_poll_path, params: { frame: request_req_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :session_limit_exceeded_server_closing_connection
    assert_correct_against_schema response_xml
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_enabled'] = 'false'
  end

  private

  def request_req_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML
  end

  def xml_schema
    Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')
  end
end
