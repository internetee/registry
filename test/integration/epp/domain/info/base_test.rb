require 'test_helper'

class EppDomainInfoBaseTest < EppTestCase
  setup do
    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_returns_valid_response
    assert_equal 'john-001', contacts(:john).code
    domains(:shop).update_columns(statuses: [DomainStatus::OK],
                                  created_at: Time.zone.parse('2010-07-05'),
                                  updated_at: Time.zone.parse('2010-07-06'),
                                  valid_to: Time.zone.parse('2010-07-07'))

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)

    assert_epp_response :completed_successfully
    assert assert_schema_is_bigger(response_xml, 'domain-ee', 1.1)
    assert_equal 'shop.test',
                 response_xml.at_xpath('//domain:name',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_equal 'ok',
                 response_xml.at_xpath('//domain:status',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s)['s']
    assert_equal 'john-001',
                 response_xml.at_xpath('//domain:registrant',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_equal '2010-07-05T00:00:00+03:00',
                 response_xml.at_xpath('//domain:crDate',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_equal '2010-07-06T00:00:00+03:00',
                 response_xml.at_xpath('//domain:upDate',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_equal '2010-07-07T00:00:00+03:00',
                 response_xml.at_xpath('//domain:exDate',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
  end

  def test_return_wrong_schema_with_invalid_version
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.0')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :wrong_schema
  end

  def test_return_valid_response_if_specify_the_version
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully
  end

  def test_return_valid_response_if_specify_the_version_1_2
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    p request_xml
    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully
  end

  def test_returns_valid_response_if_schema_version_is_previous
    dispute = disputes(:expired)
    dispute.update!(starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days, closed: nil)

    domain = domains(:shop)
    domain.update_columns(statuses: [DomainStatus::DISPUTED],
                          created_at: Time.zone.parse('2010-07-05'),
                          updated_at: Time.zone.parse('2010-07-06'),
                          creator_str: 'test',
                          valid_to: Time.zone.parse('2010-07-07'))

    domain.versions.destroy_all

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-eis', for_version: '1.0')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully

    res = parsing_schemas_prefix_and_version(response.body)

    assert_equal res[:prefix], 'domain-eis'
    assert_equal res[:version], '1.0'
  end

  def test_returns_valid_response_if_disputed
    dispute = disputes(:expired)
    dispute.update!(starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days, closed: nil)

    domain = domains(:shop)
    domain.update_columns(statuses: [DomainStatus::DISPUTED],
                          created_at: Time.zone.parse('2010-07-05'),
                          updated_at: Time.zone.parse('2010-07-06'),
                          creator_str: 'test',
                          valid_to: Time.zone.parse('2010-07-07'))

    domain.versions.destroy_all

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_returns_valid_response_if_not_throttled
    domain = domains(:shop)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{domain.name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'
    domain = domains(:shop)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>#{domain.name}</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :session_limit_exceeded_server_closing_connection
    assert_correct_against_schema response_xml
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_returns_valid_response_if_release_prohibited
    domain = domains(:shop)
    domain.update_columns(statuses: [DomainStatus::SERVER_RELEASE_PROHIBITED],
                          created_at: Time.now - 5.days,
                          creator_str: 'test',
                          delete_date: Time.now - 1.day)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_reveals_transfer_code_when_domain_is_owned_by_current_user
    assert_equal '65078d5', domains(:shop).transfer_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_equal '65078d5',
                 response_xml.at_xpath('//domain:authInfo/domain:pw',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_correct_against_schema response_xml
  end

  # Transfer code is the only info we conceal from other registrars, hence a bit oddly-looking
  # test name
  def test_reveals_transfer_code_when_domain_is_not_owned_by_current_user_and_transfer_code_is_provided
    assert_equal '65078d5', domains(:shop).transfer_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>65078d5</domain:pw>
              </domain:authInfo>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_equal '65078d5',
                 response_xml.at_xpath('//domain:authInfo/domain:pw',
                                       'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s).text
    assert_correct_against_schema response_xml
  end

  def test_conceals_transfer_code_when_domain_is_not_owned_by_current_user
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <domain:info xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw></domain:pw>
              </domain:authInfo>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, params: { frame: request_xml },
                        headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_nil response_xml.at_xpath('//domain:authInfo/domain:pw',
                                     'domain' => Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2').to_s)
  end
end
