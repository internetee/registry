require 'test_helper'

class EppDomainCreateBaseTest < EppTestCase

  def test_not_registers_domain_without_legaldoc
    old_value = Setting.legal_document_is_mandatory
    Setting.legal_document_is_mandatory = true
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :required_parameter_missing
    Setting.legal_document_is_mandatory = old_value
  end

  def test_registers_new_domain_with_required_attributes
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :completed_successfully

    domain = Domain.find_by(name: name)
    assert_equal name, domain.name
    assert_equal registrant, domain.registrant
    assert_equal [contact], domain.admin_contacts
    assert_equal [contact], domain.tech_contacts
    assert_not_empty domain.transfer_code

    default_registration_period = 1.year + 1.day
    assert_equal now + default_registration_period, domain.expire_time
  end

  def test_registers_domain_without_legaldoc_if_optout
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    registrar = registrant.registrar

    registrar.legaldoc_optout = true
    registrar.save(validate: false)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :completed_successfully

    domain = Domain.find_by(name: name)
    assert_equal name, domain.name
    assert_equal registrant, domain.registrant
  end

  def test_does_not_registers_domain_without_legaldoc_if_mandatory
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    old_value = Setting.legal_document_is_mandatory
    Setting.legal_document_is_mandatory = true
    registrar = registrant.registrar

    assert registrar.legaldoc_mandatory?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
        </command>
      </epp>
    XML


    post epp_create_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :required_parameter_missing
    Setting.legal_document_is_mandatory = false

    assert_not registrar.legaldoc_mandatory?
    assert_not Setting.legal_document_is_mandatory

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    Setting.legal_document_is_mandatory = old_value
  end

  def test_registers_reserved_domain_with_registration_code
    reserved_domain = reserved_domains(:one)
    registration_code = reserved_domain.registration_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{reserved_domain.name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>#{registration_code}</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :completed_successfully

    reserved_domain.reload
    assert_not_equal registration_code, reserved_domain.registration_code
  end

  def test_respects_custom_transfer_code
    name = "new.#{dns_zones(:one).origin}"
    transfer_code = 'custom-transfer-code'

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
              <domain:authInfo>
                <domain:pw>#{transfer_code}</domain:pw>
              </domain:authInfo>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully
    assert_equal transfer_code, Domain.find_by(name: name).transfer_code
  end

  def test_blocked_domain_cannot_be_registered
    blocked_domain = 'blocked.test'
    assert BlockedDomain.find_by(name: blocked_domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{blocked_domain}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :data_management_policy_violation
  end

  def test_blocked_punicode_domain_cannot_be_registered
    blocked_domain = 'blockedäöüõ.test'
    assert BlockedDomain.find_by(name: blocked_domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{SimpleIDN.to_ascii('blockedäöüõ.test')}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :data_management_policy_violation
  end

  def test_reserved_domain_cannot_be_registered_with_wrong_registration_code
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{reserved_domains(:one).name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>wrong</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :invalid_authorization_information
  end

  def test_reserved_domain_cannot_be_registered_without_registration_code
    reserved_domain = reserved_domains(:one)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{reserved_domain.name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :required_parameter_missing
  end

  def test_insufficient_funds
    session = epp_sessions(:api_bestnames)
    session.user.registrar.accounts.first.update!(balance: 0)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>new.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => "session=#{session.session_id}" }
    end
    assert_epp_response :billing_failure
  end

  def test_no_price
    assert_nil Billing::Price.find_by(duration: '2 months')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>new.test</domain:name>
              <domain:period unit="m">2</domain:period>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :billing_failure
  end
end
