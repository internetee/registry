require 'test_helper'

class EppAutoRenewSessionTest < EppTestCase
  setup do
    ENV['shunter_default_adapter'].constantize.new.clear!
    @session_limit = EppSession.sessions_per_registrar
    EppSession.sessions_per_registrar = 100
  end

  teardown do
    EppSession.sessions_per_registrar = @session_limit
  end

  def test_greeting_advertises_both_extensions
    get epp_hello_path,
        params: { frame: '<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd"><hello/></epp>' },
        headers: { 'HTTP_COOKIE' => 'session=auto-renew-hello' }
    xml = Nokogiri::XML(response.body)
    assert_correct_against_schema xml
    uris = xml.xpath('//epp:svcExtension/epp:extURI', epp: epp_uri).map(&:text)
    assert_includes uris, EppSession::AUTO_RENEW_URI
    assert_includes uris, EppSession::RGP_URI
  end

  def test_login_stores_only_namespaced_service_extension_uris
    user = users(:api_bestnames)
    frame = <<~XML
      <e:epp xmlns:e="#{epp_uri}">
        <e:command><e:login>
          <e:clID>#{user.username}</e:clID><e:pw>#{user.plain_text_password}</e:pw>
          <e:options><e:version>1.0</e:version><e:lang>en</e:lang></e:options>
          <e:svcs>
            <e:objURI>https://epp.tld.ee/schema/domain-ee-1.2.xsd</e:objURI>
            <e:svcExtension>
              <e:extURI>#{EppSession::AUTO_RENEW_URI}</e:extURI>
              <e:extURI>  #{EppSession::RGP_URI}  </e:extURI>
              <foreign:extURI xmlns:foreign="urn:foreign">urn:foreign</foreign:extURI>
            </e:svcExtension>
          </e:svcs>
        </e:login></e:command>
      </e:epp>
    XML
    post '/epp/session/login', params: { frame: frame },
                                headers: { 'HTTP_COOKIE' => 'session=auto-renew-login' }
    assert_epp_response :completed_successfully
    assert_correct_against_schema Nokogiri::XML(response.body)
    session = EppSession.find_by!(session_id: 'auto-renew-login')
    assert_equal [EppSession::AUTO_RENEW_URI, EppSession::RGP_URI], session.ext_uris
    assert session.extension?(EppSession::AUTO_RENEW_URI)
    assert_not session.extension?('urn:foreign')
  end

  def test_login_without_service_extensions_keeps_empty_negotiation
    user = users(:api_bestnames)
    frame = <<~XML
      <epp xmlns="#{epp_uri}"><command><login>
        <clID>#{user.username}</clID><pw>#{user.plain_text_password}</pw>
        <options><version>1.0</version><lang>en</lang></options>
        <svcs><objURI>https://epp.tld.ee/schema/domain-ee-1.2.xsd</objURI></svcs>
      </login></command></epp>
    XML
    post '/epp/session/login', params: { frame: frame },
                                headers: { 'HTTP_COOKIE' => 'session=auto-renew-legacy-login' }
    assert_epp_response :completed_successfully
    session = EppSession.find_by!(session_id: 'auto-renew-legacy-login')
    assert_equal [], session.ext_uris
    assert_not session.extension?(EppSession::RGP_URI)
  end

  private

  def epp_uri
    'https://epp.tld.ee/schema/epp-ee-1.0.xsd'
  end
end
