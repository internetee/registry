require 'test_helper'

class DummyEppController < Epp::BaseController
  def internal_error
    raise StandardError
  end
end

class EppBaseTest < EppTestCase
  def test_internal_error
    Rails.application.routes.draw do
      post 'epp/command/internal_error', to: 'dummy_epp#internal_error',
           constraints: EppConstraint.new(:poll)
    end

    any_valid_epp_request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <hello/>
      </epp>
    XML

    begin
      assert_difference 'ApiLog::EppLog.count' do
        post '/epp/command/internal_error', { frame: any_valid_epp_request_xml },
             'HTTP_COOKIE' => 'session=api_bestnames'
      end
      assert_epp_response :command_failed
    rescue
      raise
    ensure
      Rails.application.reload_routes!
    end
  end

  def test_invalid_request
    invalid_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      </epp>
    XML
    post '/epp/command/internal_error', { frame: invalid_xml },
         'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :syntax_error
  end

  def test_anonymous_user
    xml_of_epp_command_that_requires_authentication = <<-XML
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
    post '/epp/command/info', { frame: xml_of_epp_command_that_requires_authentication },
         'HTTP_COOKIE' => 'session=non-existent'

    assert_epp_response :authorization_error
  end

  def test_non_authorized_user
    session = epp_sessions(:api_bestnames)
    user = session.user
    user.update!(roles: [ApiUser::BILLING])
    assert user.cannot?(:info, Domain)

    xml_of_epp_command_that_requires_authorization = <<-XML
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
    post '/epp/command/info', { frame: xml_of_epp_command_that_requires_authorization },
         'HTTP_COOKIE' => "session=#{session.session_id}"

    assert_epp_response :authorization_error
  end
end
