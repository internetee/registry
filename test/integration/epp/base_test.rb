require 'test_helper'

class DummyEppController < Epp::BaseController
  def internal_error
    raise StandardError
  end
end

class EppBaseTest < EppTestCase
  setup do
    @original_session_timeout = EppSession.timeout
  end

  teardown do
    EppSession.timeout = @original_session_timeout
  end

  def test_internal_error
    Rails.application.routes.draw do
      post 'epp/command/internal_error', to: 'dummy_epp#internal_error',
                                         constraints: EppConstraint.new(:poll)
    end

    begin
      assert_difference 'ApiLog::EppLog.count' do
        post '/epp/command/internal_error', params: { frame: valid_request_xml },
                                            headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
      assert_epp_response :command_failed
    rescue StandardError
      raise
    ensure
      Rails.application.reload_routes!
    end
  end

  def test_wrong_path_xml
    wrong_path_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="https://dsfs.sdf.sdf">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: wrong_path_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :wrong_schema
  end

  def test_additional_error
    get '/epp/error', params: { frame: valid_request_xml },
                      headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :unknown_command
  end

  def test_error_with_unknown_command
    invalid_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epsdp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
      </epp>
    XML

    get '/epp/error', params: { frame: invalid_xml },
                      headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :unknown_command
  end

  def test_validates_request_xml
    invalid_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
      </epp>
    XML
    post valid_command_path, params: { frame: invalid_xml },
                             headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :required_parameter_missing
  end

  def test_anonymous_user
    xml_of_epp_command_that_requires_authentication = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: xml_of_epp_command_that_requires_authentication },
                        headers: { 'HTTP_COOKIE' => 'session=non-existent' }

    assert_epp_response :authorization_error
  end

  def test_non_authorized_user
    session = epp_sessions(:api_bestnames)
    user = session.user
    user.update!(roles: [ApiUser::BILLING])
    assert user.cannot?(:info, Domain)

    xml_of_epp_command_that_requires_authorization = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: xml_of_epp_command_that_requires_authorization },
                        headers: { 'HTTP_COOKIE' => "session=#{session.session_id}" }

    assert_epp_response :authorization_error
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
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post '/epp/command/info', params: { frame: authentication_enabled_epp_request_xml },
                              headers: { 'HTTP_COOKIE' => "session=#{session.session_id}" }

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
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>#{domains(:shop).name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', params: { frame: authentication_enabled_epp_request_xml },
                              headers: { 'HTTP_COOKIE' => "session=#{session.session_id}" }

    session.reload

    assert_epp_response :completed_successfully
    assert_equal now, session.last_access
  end

  private

  def valid_command_path
    epp_poll_path
  end

  def valid_request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <hello/>
      </epp>
    XML
  end
end
