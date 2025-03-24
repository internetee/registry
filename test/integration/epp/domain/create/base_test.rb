require 'test_helper'

class EppDomainCreateBaseTest < EppTestCase
  setup do
    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_illegal_chars_in_dns_key
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    pub_key = "AwEAAddt2AkLf\n
    \n
    YGKgiEZB5SmIF8E\n
    vrjxNMH6HtxW\rEA4RJ9Ao6LCWheg8"

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
          <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
          <secDNS:keyData>
            <secDNS:flags>257</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>8</secDNS:alg>
            <secDNS:pubKey>#{pub_key}</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:create>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_syntax_error
  end

  def test_too_small_legal_document
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :data_management_policy_violation
  end

  def test_too_big_legal_document
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    bignum_legaldoc = Base64.encode64('t' * (LegalDocument::MAX_BODY_SIZE + 1)).gsub(/\n/,"")

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{bignum_legaldoc}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :data_management_policy_violation
    error_description = 'Legaldoc size exceeds maximum allowed size of 8mB'
    assert response.body.include? error_description
  end

  def test_upper_limit_of_value_legal_document
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    bignum_legaldoc = 't' * LegalDocument::MAX_BODY_SIZE

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{bignum_legaldoc}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :completed_successfully
  end



  def test_not_registers_domain_without_legaldoc
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :required_parameter_missing
  end

  def test_create_domain_with_unique_contact
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contacts(:jane).code}</domain:contact>
              <domain:contact type="tech">#{contacts(:william).code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end


  def test_create_domain_with_array_of_not_unique_admins_and_techs
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_policy_error
  end

  def test_create_domain_with_array_of_not_unique_admins
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_policy_error
  end

  def test_create_domain_with_array_of_not_unique_techs
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_policy_error
  end

  def test_create_domain_with_array_of_not_unique_admin_but_tech_another_one
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    contact_two = contacts(:william)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="admin">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact_two.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_policy_error
  end

  def test_create_domain_with_array_of_not_unique_techs_but_admin_another_one
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    contact_two = contacts(:william)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact_two.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
              <domain:contact type="tech">#{contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :parameter_value_policy_error
  end

  def test_registers_new_domain_with_private_registrant_without_admin_contacts
    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    registrant.update!(ident_type: 'priv')
    registrant.reload
    assert_not registrant.org?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :completed_successfully

    domain = Domain.find_by(name: name)
    assert_equal name, domain.name
    assert_equal registrant, domain.registrant
    assert_empty domain.admin_contacts
    assert_empty domain.tech_contacts
    assert_not_empty domain.transfer_code

    default_registration_period = 1.year + 1.day
    assert_equal now + default_registration_period, domain.expire_time
  end

  def test_does_not_register_domain_for_legal_entity_without_admin_contact
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    
    # Устанавливаем регистранта как юр.лицо
    registrant.update!(ident_type: 'org')
    registrant.reload
    assert registrant.org?
    
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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

    assert_epp_response :parameter_value_range_error
  end

  def test_does_not_register_domain_for_underage_estonian_id_without_admin_contact
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    
    registrant.update!(
      ident_type: 'priv',
      ident: '61203150222',
      ident_country_code: 'EE'
    )
    registrant.reload
    assert registrant.priv?
    
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    
    assert_epp_response :parameter_value_range_error
  end

  def test_registers_domain_for_adult_estonian_id_without_admin_contact
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    
    registrant.update!(
      ident_type: 'priv',
      ident: '38903111310',
      ident_country_code: 'EE'
    )
    registrant.reload
    assert registrant.priv?
    
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
  end

  def test_registers_new_domain_with_required_attributes
    Setting.admin_contacts_allowed_ident_type = { 'org' => true, 'priv' => true, 'birthday' => true }.to_json

    now = Time.zone.parse('2010-07-05')
    travel_to now
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)

    registrant.update!(ident_type: 'org')
    registrant.reload

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :completed_successfully

    domain = Domain.find_by(name: name)
    assert_equal name, domain.name
    assert_equal registrant, domain.registrant
    assert_equal [contact], domain.admin_contacts
    assert_empty domain.tech_contacts
    assert_not_empty domain.transfer_code

    default_registration_period = 1.year + 1.day
    assert_equal now + default_registration_period, domain.expire_time

    Setting.admin_contacts_allowed_ident_type = { 'org' => false, 'priv' => true, 'birthday' => true }.to_json
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
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

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
    registrar = registrant.registrar

    assert registrar.legaldoc_mandatory?

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
            </domain:create>
          </create>
        </command>
      </epp>
    XML


    post epp_create_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml

    assert_epp_response :required_parameter_missing
    Setting.legal_document_is_mandatory = false

    assert_not registrar.legaldoc_mandatory?
    assert_not Setting.legal_document_is_mandatory

    assert_difference 'Domain.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
  end

  def test_registers_reserved_domain_with_registration_code
    reserved_domain = reserved_domains(:one)
    registration_code = reserved_domain.registration_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{reserved_domain.name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully

    reserved_domain.reload
    assert_not_equal registration_code, reserved_domain.registration_code
  end

  def test_respects_custom_transfer_code
    name = "new.#{dns_zones(:one).origin}"
    transfer_code = 'custom-transfer-code'

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
              <domain:authInfo>
                <domain:pw>#{transfer_code}</domain:pw>
              </domain:authInfo>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal transfer_code, Domain.find_by(name: name).transfer_code
  end

  def test_blocked_domain_cannot_be_registered
    blocked_domain = 'blocked.test'
    assert BlockedDomain.find_by(name: blocked_domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{blocked_domain}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :data_management_policy_violation
  end

  def test_blocked_punicode_domain_cannot_be_registered
    blocked_domain = 'blockedäöüõ.test'
    assert BlockedDomain.find_by(name: blocked_domain)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{SimpleIDN.to_ascii('blockedäöüõ.test')}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :data_management_policy_violation
  end

  def test_reserved_domain_cannot_be_registered_with_wrong_registration_code
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{reserved_domains(:one).name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :invalid_authorization_information
  end

  def test_reserved_domain_cannot_be_registered_without_registration_code
    reserved_domain = reserved_domains(:one)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{reserved_domain.name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :required_parameter_missing
  end

  def test_insufficient_funds
    session = epp_sessions(:api_bestnames)
    session.user.registrar.accounts.first.update!(balance: 0)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>new.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :billing_failure
  end

  def test_no_price
    assert_nil Billing::Price.find_by(duration: '2 months')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>new.test</domain:name>
              <domain:period unit="m">2</domain:period>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :billing_failure
  end

  def test_registers_disputed_domain_with_password
    now = Time.zone.parse('2010-07-05')
    travel_to now
    disputed_domain = disputes(:active)
    password = disputed_domain.password

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{disputed_domain.domain_name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>#{password}</eis:pw>
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
    response_xml = Nokogiri::XML(response.body)

    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end

  def test_returns_valid_response_if_not_throttled
    now = Time.zone.parse('2010-07-05')
    travel_to now
    disputed_domain = disputes(:active)
    password = disputed_domain.password

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{disputed_domain.domain_name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>#{password}</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    now = Time.zone.parse('2010-07-05')
    travel_to now
    disputed_domain = disputes(:active)
    password = disputed_domain.password

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{disputed_domain.domain_name}</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>#{password}</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :session_limit_exceeded_server_closing_connection
    assert_correct_against_schema response_xml
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_does_not_register_domain_with_invalid_admin_contact_ident_type
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    admin_contact = contacts(:william)
    admin_contact.update!(ident_type: 'org')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{admin_contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :parameter_value_policy_error
  end

  def test_registers_domain_with_valid_admin_contact_ident_type
    name = "new.#{dns_zones(:one).origin}"
    contact = contacts(:john)
    registrant = contact.becomes(Registrant)
    admin_contact = contacts(:william)
    admin_contact.update!(ident_type: 'priv')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <domain:create xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{name}</domain:name>
              <domain:registrant>#{registrant.code}</domain:registrant>
              <domain:contact type="admin">#{admin_contact.code}</domain:contact>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
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
    
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end
end
