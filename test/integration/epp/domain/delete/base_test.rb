require 'test_helper'

class EppDomainDeleteBaseTest < EppTestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    @original_confirmation_setting = Setting.request_confirmation_on_domain_deletion_enabled
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Setting.request_confirmation_on_domain_deletion_enabled = @original_confirmation_setting
  end

  def test_bypasses_domain_and_registrant_and_contacts_validation
    assert_equal 'invalid.test', domains(:invalid).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>invalid.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    assert_includes Domain.find_by(name: 'invalid.test').statuses, DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_epp_response :completed_successfully_action_pending
  end

  def test_discarded_domain_cannot_be_deleted
    assert_equal 'shop.test', @domain.name
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :object_status_prohibits_operation
  end

  def test_requests_registrant_confirmation_when_required
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = true

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @domain.reload

    assert @domain.registrant_verification_asked?
    assert @domain.pending_delete_confirmation?
    assert_emails 1
    assert_epp_response :completed_successfully_action_pending
  end

  def test_skips_registrant_confirmation_when_not_required
    assert_equal 'shop.test', @domain.name
    Setting.request_confirmation_on_domain_deletion_enabled = false

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
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
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete verified="yes" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @domain.reload

    assert_not @domain.registrant_verification_asked?
    assert_not @domain.pending_delete_confirmation?
    assert_no_emails
    assert_epp_response :completed_successfully
  end

  def test_legal_document_is_required
    assert_equal 'shop.test', @domain.name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :required_parameter_missing
  end

  def test_domain_cannot_be_deleted_when_explicitly_prohibited_by_registrar
    assert_equal 'shop.test', @domain.name
    @domain.update!(statuses: [DomainStatus::CLIENT_DELETE_PROHIBITED])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :object_status_prohibits_operation
  end

  def test_domain_not_found
    assert_nil Domain.find_by(name: 'non-existing.test')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>non-existing.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :object_does_not_exist
  end
end