require 'test_helper'

class EppDomainUpdateBaseTest < EppTestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    @contact = contacts(:john)
    @original_registrant_change_verification =
    Setting.request_confirmation_on_registrant_change_enabled
    ActionMailer::Base.deliveries.clear

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  teardown do
    Setting.request_confirmation_on_registrant_change_enabled =
      @original_registrant_change_verification
  end

  def test_update_dnskey_with_invalid_alg
    request_xml = <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
              <command>
                <update>
                  <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
                    <domain:name>shop.test</domain:name>
                  </domain:update>
                </update>
      <extension>
            <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
              <secDNS:add><secDNS:keyData>
      	  <secDNS:flags>257</secDNS:flags>
      	  <secDNS:protocol>3</secDNS:protocol>
      	  <secDNS:alg>666</secDNS:alg>
      	  <secDNS:pubKey>P25MwGXr2sTbxdOIKRNbSC8bUO2CObo4/T8kMFoKcgs=</secDNS:pubKey>
      	</secDNS:keyData></secDNS:add>
            </secDNS:update>
          </extension>
              </command>
            </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :parameter_value_syntax_error
  end

  def test_update_domain_data_out_of_extension_block_with_serverObjUpdateProhibited
    ENV['obj_and_extensions_prohibited'] = 'true'
    @domain = domains(:shop)
    @domain.statuses << DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
    @domain.save
    @dnskey = dnskeys(:one)
    @dnskey.update(domain: @domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:rem>
              <domain:ns>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns1).hostname}</domain:hostName>
                </domain:hostAttr>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns2).hostname}</domain:hostName>
                </domain:hostAttr>
              </domain:ns>
              <secDNS:keyData>
                <secDNS:flags>#{@dnskey.flags}</secDNS:flags>
                <secDNS:protocol>#{@dnskey.protocol}</secDNS:protocol>
                <secDNS:alg>#{@dnskey.alg}</secDNS:alg>
                <secDNS:pubKey>#{@dnskey.public_key}</secDNS:pubKey>
              </secDNS:keyData>
            </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload

    assert_epp_response :object_status_prohibits_operation
    ENV['obj_and_extensions_prohibited'] = nil
  end

  def test_update_domain_data_out_of_extension_block_with_extension_update_prohibited
    ENV['obj_and_extensions_prohibited'] = 'true'
    @domain = domains(:shop)
    @domain.statuses << DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED
    @domain.save

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:rem>
              <domain:ns>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns1).hostname}</domain:hostName>
                </domain:hostAttr>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns2).hostname}</domain:hostName>
                </domain:hostAttr>
              </domain:ns>
            </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload

    assert_epp_response :completed_successfully
    ENV['obj_and_extensions_prohibited'] = nil
  end

  def test_update_domain_dns_with_extension_update_prohibited
    ENV['obj_and_extensions_prohibited'] = 'true'
    @domain = domains(:shop)
    @domain.statuses << DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED
    @domain.save
    @dnskey = dnskeys(:one)
    @dnskey.update(domain: @domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:update>
          </update>
          <extension>
          <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
            <secDNS:rem>
              <secDNS:keyData>
                <secDNS:flags>#{@dnskey.flags}</secDNS:flags>
                <secDNS:protocol>#{@dnskey.protocol}</secDNS:protocol>
                <secDNS:alg>#{@dnskey.alg}</secDNS:alg>
                <secDNS:pubKey>#{@dnskey.public_key}</secDNS:pubKey>
              </secDNS:keyData>
            </secDNS:rem>
          </secDNS:update>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload

    assert_epp_response :object_status_prohibits_operation
    ENV['obj_and_extensions_prohibited'] = nil
  end

  def test_update_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
                <domain:chg>
                  <domain:authInfo>
                    <domain:pw>f0ff7d17b0</domain:pw>
                  </domain:authInfo>
                </domain:chg>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload
    assert_equal 'f0ff7d17b0', @domain.transfer_code
    assert_epp_response :completed_successfully
  end

  def test_discarded_domain_cannot_be_updated
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_epp_response :object_status_prohibits_operation
  end

  def test_prohibited_domain_cannot_be_updated
    @domain.update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :object_status_prohibits_operation
  end

  def test_does_not_return_server_delete_prohibited_status_when_pending_update_status_is_set
    @domain.update!(statuses: [DomainStatus::SERVER_DELETE_PROHIBITED,
                               DomainStatus::PENDING_UPDATE])
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :object_status_prohibits_operation
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal DomainStatus::PENDING_UPDATE, response_xml.at_xpath('//domain:status', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}").text
  end

  def test_requires_verification_from_current_registrant_when_provided_registrant_is_a_new_one
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william).becomes(Registrant)
    assert_not_equal new_registrant, @domain.registrant

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_enqueued_jobs
    assert_enqueued_jobs 3 do
      post epp_update_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully_action_pending
    assert_not_equal new_registrant, @domain.registrant
    assert @domain.registrant_verification_asked?
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_domain_should_doesnt_have_pending_update_when_updated_registrant_with_same_idents_data
    assert_not @domain.statuses.include? "pendingUpdate"

    old_registrant = @domain.registrant
    new_registrant = contacts(:william).becomes(Registrant)

    new_registrant.update(ident: old_registrant.ident)
    new_registrant.update(ident_country_code: old_registrant.ident_country_code)
    new_registrant.update(ident_type: old_registrant.ident_type)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="no">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload
    assert_epp_response :completed_successfully
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_equal @domain.registrant, new_registrant
    assert_not @domain.statuses.include? "pendingUpdate"
  end

  def test_requires_verification_from_current_registrant_when_not_yet_verified_by_registrar
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="no">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_enqueued_jobs
    assert_enqueued_jobs 3 do
      post epp_update_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully_action_pending
    assert_not_equal new_registrant, @domain.registrant
    assert @domain.registrant_verification_asked?
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_updates_registrant_when_legaldoc_is_not_mandatory
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    @domain.registrar.legaldoc_optout = true
    @domain.registrar.save(validate: false)
    @domain.registrar.reload

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="no">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    assert_no_enqueued_jobs
    assert_enqueued_jobs 3 do
      post epp_update_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully_action_pending
    assert_not_equal new_registrant, @domain.registrant
    assert @domain.registrant_verification_asked?
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_dows_not_update_registrant_when_legaldoc_is_mandatory
    Setting.request_confirmation_on_registrant_change_enabled = true
    old_value = Setting.legal_document_is_mandatory
    Setting.legal_document_is_mandatory = true
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="no">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :required_parameter_missing
    Setting.legal_document_is_mandatory = old_value
  end

  # ================================================================
  def test_domain_should_not_padding_if_registrant_update_with_same_ident
    Setting.request_confirmation_on_registrant_change_enabled = true

    current = @domain.registrant
    new_registrant = contacts(:william)
    new_registrant.update(
                          ident: current.ident,
                          ident_type: current.ident_type,
                          ident_country_code: current.ident_country_code
                          )

    request_xml = <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="no"?>
          <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
            <command>
              <update>
                <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
                  <domain:name>#{@domain.name}</domain:name>
                    <domain:chg>
                      <domain:registrant>#{new_registrant.code}</domain:registrant>
                    </domain:chg>
                </domain:update>
              </update>
              <extension>
                <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
                  <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
                </eis:extdata>
              </extension>
            </command>
          </epp>
        XML

    post epp_update_path, params: { frame: request_xml },
    headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    # NOTE: completed_successfully_action_pending
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_skips_verification_when_provided_registrant_is_the_same_as_current_one
    Setting.request_confirmation_on_registrant_change_enabled = true

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{@domain.registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_not @domain.registrant_verification_asked?
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_no_emails
  end

  def test_skips_verification_when_registrant_changed_with_dispute_password
    Setting.request_confirmation_on_registrant_change_enabled = true
    dispute = disputes(:expired)
    dispute.update!(starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days, closed: nil)
    new_registrant = contacts(:william)

    old_transfer_code = @domain.transfer_code

    assert @domain.disputed?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>#{dispute.password}</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert new_registrant, @domain.registrant
    assert_not @domain.registrant_verification_asked?
    assert_not @domain.disputed?
    assert_no_emails
    refute_equal @domain.transfer_code, old_transfer_code
  end

  def test_dispute_password_mandatory_when_registrant_changed
    Setting.request_confirmation_on_registrant_change_enabled = true
    dispute = disputes(:expired)
    dispute.update!(starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days, closed: nil)
    new_registrant = contacts(:william)

    assert @domain.disputed?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="yes">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>'123456'</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :invalid_authorization_information
    assert_not_equal new_registrant, @domain.registrant
    assert @domain.disputed?
    assert_no_emails
  end

  def test_skips_verification_when_disabled
    Setting.request_confirmation_on_registrant_change_enabled = false
    new_registrant = contacts(:william).becomes(Registrant)
    assert_not_equal new_registrant, @domain.registrant

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal new_registrant, @domain.registrant
    assert_not @domain.registrant_verification_asked?
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_no_emails
  end

  def test_skips_verification_from_current_registrant_when_already_verified_by_registrar
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william).becomes(Registrant)
    assert_not_equal new_registrant, @domain.registrant

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="yes">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal new_registrant, @domain.registrant
    assert_not @domain.registrant_verification_asked?
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_no_emails
  end

  def test_clears_force_delete_when_registrar_changed
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william).becomes(Registrant)
    @domain.schedule_force_delete(type: :fast_track)
    assert_not_equal new_registrant, @domain.registrant
    assert @domain.force_delete_scheduled?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant verified="yes">#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal new_registrant, @domain.registrant
    assert_not @domain.registrant_verification_asked?
    refute @domain.force_delete_scheduled?
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_no_emails
  end

  def test_deactivates_domain_when_all_name_servers_are_removed
    assert @domain.active?
    assert_equal 2, @domain.nameservers.count

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
              <domain:rem>
                <domain:ns>
                  <domain:hostAttr>
                    <domain:hostName>#{nameservers(:shop_ns1).hostname}</domain:hostName>
                  </domain:hostAttr>
                  <domain:hostAttr>
                    <domain:hostName>#{nameservers(:shop_ns2).hostname}</domain:hostName>
                  </domain:hostAttr>
                </domain:ns>
              </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload

    assert_epp_response :completed_successfully
    assert @domain.inactive?
  end

  def test_update_domain_allows_add_of_client_hold
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
                <domain:add>
                  <domain:status s="clientHold" lang="en">Test</domain:status>
                </domain:add>
              </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload
    assert_epp_response :completed_successfully
    assert_includes(@domain.statuses, DomainStatus::CLIENT_HOLD)
  end

  def test_update_domain_allows_remove_of_client_hold
    @domain.update!(statuses: [DomainStatus::CLIENT_HOLD, DomainStatus::FORCE_DELETE,
                               DomainStatus::SERVER_RENEW_PROHIBITED,
                               DomainStatus::SERVER_TRANSFER_PROHIBITED])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
                <domain:rem>
                  <domain:status s="clientHold" lang="en">Test</domain:status>
                </domain:rem>
              </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload
    assert_epp_response :completed_successfully
    assert_not_includes(@domain.statuses, DomainStatus::CLIENT_HOLD)
  end

  def test_update_domain_returns_error_when_removing_unassigned_status
    assert_not_includes(@domain.statuses, DomainStatus::CLIENT_HOLD)
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
            <domain:name>#{@domain.name}</domain:name>
              <domain:rem>
                <domain:status s="clientHold"/>
              </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload
    assert_epp_response :object_does_not_exist
  end

  def test_returns_valid_response_if_not_throttled
    ENV['obj_and_extensions_prohibited'] = 'true'
    @domain = domains(:shop)
    @domain.statuses << DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED
    @domain.save

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:rem>
              <domain:ns>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns1).hostname}</domain:hostName>
                </domain:hostAttr>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns2).hostname}</domain:hostName>
                </domain:hostAttr>
              </domain:ns>
            </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'
    ENV['obj_and_extensions_prohibited'] = 'true'
    @domain = domains(:shop)
    @domain.statuses << DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED
    @domain.save

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:rem>
              <domain:ns>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns1).hostname}</domain:hostName>
                </domain:hostAttr>
                <domain:hostAttr>
                  <domain:hostName>#{nameservers(:shop_ns2).hostname}</domain:hostName>
                </domain:hostAttr>
              </domain:ns>
            </domain:rem>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :session_limit_exceeded_server_closing_connection
    assert_correct_against_schema response_xml
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_does_not_update_domain_with_invalid_admin_contact_ident_type
    admin_contact = contacts(:william)
    admin_contact.update!(ident_type: 'org')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:add>
                <domain:contact type="admin">#{admin_contact.code}</domain:contact>
              </domain:add>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :parameter_value_policy_error
  end

  def test_updates_domain_with_valid_admin_contact_ident_type
    admin_contact = contacts(:william)
    admin_contact.update!(ident_type: 'priv')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:add>
                <domain:contact type="admin">#{admin_contact.code}</domain:contact>
              </domain:add>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end

  def test_skips_admin_contact_ident_type_validation_for_existing_contacts
    admin_contact = contacts(:william)
    admin_contact.update!(ident_type: 'org')
    @domain.admin_contacts << admin_contact
    @domain.save!

    # Change allowed types after domain is created
    Setting.admin_contacts_allowed_ident_type = { 'birthday' => true, 'priv' => true, 'org' => false }.to_json

    # Try to update domain with some other changes
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
              <domain:chg>
                <domain:authInfo>
                  <domain:pw>new_pw</domain:pw>
                </domain:authInfo>
              </domain:chg>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end

  def test_does_not_allow_underage_admin_contact
    admin_contact = contacts(:william)
    admin_contact.update!(
      ident_type: 'priv',
      ident: '61203150222',
      ident_country_code: 'EE'
    )

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
              <domain:add>
                <domain:contact type="admin">#{admin_contact.code}</domain:contact>
              </domain:add>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :object_status_prohibits_operation
  end

  # UPDATE TESTS FOR DUPLICATE CONTACTS
  def test_update_domain_with_duplicate_registrant_and_single_admin
    domain = domains(:shop)
    
    duplicate_contact = Contact.create!(
      name: 'Partial Duplicate Test',
      code: 'duplicate-006',
      email: 'partial-duplicate@test.com',
      phone: '+123.6789012',
      ident: '12349X',
      ident_type: 'priv',
      ident_country_code: 'US',
      registrar: registrars(:bestnames)
    )
    
    registrant = duplicate_contact.becomes(Registrant)
    
    new_admin = Contact.create!(
      name: duplicate_contact.name,
      code: 'duplicate-admin-006',
      email: duplicate_contact.email,
      phone: duplicate_contact.phone,
      ident: duplicate_contact.ident,
      ident_type: 'priv',
      ident_country_code: duplicate_contact.ident_country_code,
      registrar: registrars(:bestnames)
    )

    domain.update(registrant: registrant) && domain.reload

    old_admin = domain.admin_contacts.first

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{domain.name}</domain:name>
              <domain:chg/>
              <domain:add>
                <domain:contact type="admin">#{new_admin.code}</domain:contact>
              </domain:add>
              <domain:rem>
                <domain:contact type="admin">#{old_admin.code}</domain:contact>
              </domain:rem>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path(domain_name: domain.name), params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    domain.reload

    assert_epp_response :completed_successfully
    assert response.body.include? "Admin contact #{new_admin.code} was discarded as duplicate;"
  end

  def test_update_domain_with_registrant_admin_tech_all_duplicates
    domain = domains(:airport)

    initial_admin_contact = contacts(:jane)
    initial_tech_contact = contacts(:william)
    domain.admin_contacts = [initial_admin_contact]
    domain.tech_contacts = [initial_tech_contact]
    domain.save!
    domain.reload

    base_duplicate_data_contact = Contact.create!(
      name: 'All Roles Are The Same Person',
      code: "base-all-roles-#{SecureRandom.hex(3)}",
      email: 'all.roles.same.person@example.com',
      phone: '+1.999888777',
      ident: 'ARSAMEP123',
      ident_type: 'priv',
      ident_country_code: 'US',
      registrar: domain.registrar
    )

    new_registrant = base_duplicate_data_contact.becomes(Registrant)
    domain.update!(registrant: new_registrant)
    domain.reload

    new_admin_being_added = Contact.create!(
      name: base_duplicate_data_contact.name,
      code: "admin-dup-all-roles-#{SecureRandom.hex(3)}",
      email: base_duplicate_data_contact.email,
      phone: base_duplicate_data_contact.phone,
      ident: base_duplicate_data_contact.ident,
      ident_type: base_duplicate_data_contact.ident_type,
      ident_country_code: base_duplicate_data_contact.ident_country_code,
      registrar: domain.registrar
    )

    new_tech_being_added = Contact.create!(
      name: base_duplicate_data_contact.name,
      code: "tech-dup-all-roles-#{SecureRandom.hex(3)}",
      email: base_duplicate_data_contact.email,
      phone: base_duplicate_data_contact.phone,
      ident: base_duplicate_data_contact.ident,
      ident_type: base_duplicate_data_contact.ident_type,
      ident_country_code: base_duplicate_data_contact.ident_country_code,
      registrar: domain.registrar
    )

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{domain.name}</domain:name>
              <domain:chg/>
              <domain:add>
                <domain:contact type="admin">#{new_admin_being_added.code}</domain:contact>
                <domain:contact type="tech">#{new_tech_being_added.code}</domain:contact>
              </domain:add>
              <domain:rem>
                <domain:contact type="admin">#{initial_admin_contact.code}</domain:contact>
                <domain:contact type="tech">#{initial_tech_contact.code}</domain:contact>
              </domain:rem>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path(domain_name: domain.name), params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => "session=api_bestnames" }
    domain.reload

    assert_epp_response :completed_successfully
    assert response.body.include? "Admin contact #{new_admin_being_added.code} was discarded as duplicate;"
    assert response.body.include? "Tech contact #{new_tech_being_added.code} was discarded as duplicate;"
  end

  def test_update_domain_with_duplicate_admin_and_tech_registrant_is_different
    domain = domains(:library)

    initial_admin_contact = contacts(:john)
    initial_tech_contact = contacts(:william)
    domain.admin_contacts = [initial_admin_contact]
    domain.tech_contacts = [initial_tech_contact]
    domain.save!
    domain.reload

    admin_tech_duplicate_base = Contact.create!(
      name: 'Admin And Tech Are Same Person',
      code: "base-adm-tech-#{SecureRandom.hex(3)}",
      email: 'admin.tech.same.person@example.com',
      phone: '+1.555444333',
      ident: 'ATSAMEP456',
      ident_type: 'priv',
      ident_country_code: 'US',
      registrar: domain.registrar
    )

    new_admin_being_added = Contact.create!(
      name: admin_tech_duplicate_base.name,
      code: "admin-dup-adm-tech-#{SecureRandom.hex(3)}",
      email: admin_tech_duplicate_base.email,
      phone: admin_tech_duplicate_base.phone,
      ident: admin_tech_duplicate_base.ident,
      ident_type: admin_tech_duplicate_base.ident_type,
      ident_country_code: admin_tech_duplicate_base.ident_country_code,
      registrar: domain.registrar
    )

    new_tech_being_added_and_skipped = Contact.create!(
      name: admin_tech_duplicate_base.name,
      code: "tech-dup-adm-tech-#{SecureRandom.hex(3)}",
      email: admin_tech_duplicate_base.email,
      phone: admin_tech_duplicate_base.phone,
      ident: admin_tech_duplicate_base.ident,
      ident_type: admin_tech_duplicate_base.ident_type,
      ident_country_code: admin_tech_duplicate_base.ident_country_code,
      registrar: domain.registrar
    )

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{domain.name}</domain:name>
              <domain:chg/>
              <domain:add>
                <domain:contact type="admin">#{new_admin_being_added.code}</domain:contact>
                <domain:contact type="tech">#{new_tech_being_added_and_skipped.code}</domain:contact>
              </domain:add>
              <domain:rem>
                <domain:contact type="admin">#{initial_admin_contact.code}</domain:contact>
                <domain:contact type="tech">#{initial_tech_contact.code}</domain:contact>
              </domain:rem>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path(domain_name: domain.name), params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => "session=api_bestnames" }
    domain.reload

    assert_epp_response :completed_successfully
    assert response.body.include? "Tech contact #{new_tech_being_added_and_skipped.code} was discarded as duplicate;"
  end

  private

  def assert_verification_and_notification_emails
    assert_emails 2
  end
end
