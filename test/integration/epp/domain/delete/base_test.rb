require 'test_helper'

class EppDomainDeleteBaseTest < EppTestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    @original_domain_delete_confirmation = Setting.request_confirmation_on_domain_deletion_enabled
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Setting.request_confirmation_on_domain_deletion_enabled = @original_domain_delete_confirmation
  end

  def test_bypasses_domain_and_registrant_and_contacts_validation
    assert_equal 'invalid.test', domains(:invalid).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>invalid.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_includes Domain.find_by(name: 'invalid.test').statuses, DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_epp_response :completed_successfully_action_pending
  end

  def test_discarded_domain_cannot_be_deleted
    assert_equal 'shop.test', @domain.name
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :object_status_prohibits_operation
  end

  def test_requests_registrant_confirmation_when_required
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = true

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    perform_enqueued_jobs do
      post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload

    assert @domain.registrant_verification_asked?
    assert @domain.pending_delete_confirmation?
    assert_epp_response :completed_successfully_action_pending
    assert_emails 1
  end

  def test_skips_registrant_confirmation_when_not_required
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = false

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    perform_enqueued_jobs do
      post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload

    assert_not @domain.registrant_verification_asked?
    assert_not @domain.pending_delete_confirmation?
    assert_no_emails
    assert_epp_response :completed_successfully
  end

  def test_deletes_on_update_prohibited
    assert_equal 'shop.test', @domain.name
    @domain.update(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    Setting.request_confirmation_on_domain_deletion_enabled = false

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    perform_enqueued_jobs do
      post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    @domain.reload

    assert_not @domain.registrant_verification_asked?
    assert_not @domain.pending_delete_confirmation?
    assert_no_emails
    assert_epp_response :completed_successfully
  end

  def test_skips_registrant_confirmation_when_required_but_already_verified_by_registrar
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = true

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete verified="yes" xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    perform_enqueued_jobs do
      post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload

    assert_not @domain.registrant_verification_asked?
    assert_not @domain.pending_delete_confirmation?
    assert_no_emails
    assert_epp_response :completed_successfully
  end

  def test_legal_document_is_optional
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = false

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
        </command>
      </epp>
    XML

    post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :completed_successfully
  end

  def test_domain_cannot_be_deleted_when_explicitly_prohibited_by_registrar
    assert_equal 'shop.test', @domain.name
    @domain.update!(statuses: [DomainStatus::CLIENT_DELETE_PROHIBITED])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <delete>
            <domain:delete xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_delete_path, params: { frame: request_xml }, headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :object_status_prohibits_operation
  end
end
