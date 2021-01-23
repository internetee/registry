require 'test_helper'

class EppDomainTransferRequestTest < EppTestCase
  def setup
    @domain = domains(:shop)
    @contact = contacts(:jane)
    @new_registrar = registrars(:goodnames)
    @original_transfer_wait_time = Setting.transfer_wait_time
    Setting.transfer_wait_time = 0
  end

  def teardown
    Setting.transfer_wait_time = @original_transfer_wait_time
  end

  def test_transfer_domain_with_contacts_if_registrant_and_tech_are_shared
    registrar_id = @domain.registrar.id
    new_contact = Contact.find_by(registrar_id: registrar_id)

    @domain.tech_domain_contacts[0].update!(contact_id: new_contact.id)

    # ????????
    @domain.tech_domain_contacts[1].delete
    @domain.reload
    # ???????

    post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    @domain.reload

    contact_fresh = Contact.find_by(id: @domain.tech_domain_contacts[0].contact_id)

    assert_epp_response :completed_successfully
    result_hash = @domain.contacts.pluck(:original_id).group_by(&:itself).transform_values(&:count)
    assert result_hash[new_contact.id] < 2

    result_hash_codes = @domain.contacts.pluck(:code).group_by(&:itself).transform_values(&:count)
    assert result_hash_codes[contact_fresh.code] < 2

    assert_equal new_contact.phone, contact_fresh.phone
    assert_equal new_contact.name, contact_fresh.name
    assert_equal new_contact.ident, contact_fresh.ident
  end

  # # ???????????????????
  # def test_transfer_domain_with_contacts_if_registrant_and_admin_are_shared
  #   registrar_id = @domain.registrar.id
  #   new_contact = Contact.find_by(registrar_id: registrar_id)

  #   @domain.admin_domain_contacts[0].update!(contact_id: new_contact.id)
  #   @domain.tech_domain_contacts[0].update!(contact_id: '999914115') # ?????????
    
  #   # ????????? need to find out
  #   @domain.tech_domain_contacts[1].delete
  #   @domain.reload
  #   # ??????????????????????????

  #   post epp_transfer_path, params: { frame: request_xml },
  #          headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

  #   @domain.reload

  #   contact_one = Contact.find_by(id: @domain.admin_domain_contacts[0].contact_id)
  #   contact_two = Contact.find_by(id: @domain.tech_domain_contacts[0].contact_id)

  #   assert_epp_response :completed_successfully
  #   result_hash = @domain.contacts.pluck(:original_id).group_by(&:itself).transform_values(&:count)
  #   assert result_hash[new_contact.id] < 2

  #   result_hash_codes = @domain.contacts.pluck(:code).group_by(&:itself).transform_values(&:count)
  #   assert result_hash_codes[contact_one.code] < 2
  #   assert result_hash_codes[contact_two.code] < 2

  # end

  def test_transfer_domain_with_contacts_if_admin_and_tech_are_shared
    @domain.admin_domain_contacts[0].update!(contact_id: @contact.id)
    @domain.tech_domain_contacts[0].update!(contact_id: @contact.id)

    post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    @domain.reload

    contact_fresh = Contact.find_by(id: @domain.admin_domain_contacts[0].contact_id)

    assert_epp_response :completed_successfully
    result_hash = @domain.contacts.pluck(:original_id).group_by(&:itself).transform_values(&:count)
    assert_equal result_hash[contact_fresh.original_id], 2

    result_hash_codes = @domain.contacts.pluck(:code).group_by(&:itself).transform_values(&:count)
    assert result_hash_codes[contact_fresh.code] > 1

    assert_equal @contact.phone, contact_fresh.phone
    assert_equal @contact.name, contact_fresh.name
    assert_equal @contact.ident, contact_fresh.ident
  end

  def test_transfer_domain_with_contacts_if_admin_and_tech_and_registrant_are_shared
    registrar_id = @domain.registrar.id
    contact = Contact.find_by(registrar_id: registrar_id)
    
    @domain.admin_domain_contacts[0].update!(contact_id: contact.id)
    @domain.tech_domain_contacts[0].update!(contact_id: contact.id)

    post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    @domain.reload

    contact_fresh = Contact.find_by(id: @domain.admin_domain_contacts[0].contact_id)

    assert_epp_response :completed_successfully
    result_hash = @domain.contacts.pluck(:original_id).group_by(&:itself).transform_values(&:count)
    assert_equal result_hash[contact.id], 2
    
    result_hash_codes = @domain.contacts.pluck(:code).group_by(&:itself).transform_values(&:count)
    assert result_hash_codes[contact_fresh.code] > 1

    assert_equal contact.phone, contact_fresh.phone
    assert_equal contact.name, contact_fresh.name
    assert_equal contact.ident, contact_fresh.ident
  end

  def test_transfers_domain_at_once
    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_epp_response :completed_successfully
  end

  def test_creates_new_domain_transfer
    assert_difference -> { @domain.transfers.size } do
      post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_approves_automatically_if_auto_approval_is_enabled
    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_equal 'serverApproved', Nokogiri::XML(response.body).xpath('//domain:trStatus', 'domain' =>
      'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_assigns_new_registrar
    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload
    assert_equal @new_registrar, @domain.registrar
  end

  def test_regenerates_transfer_code
    @old_transfer_code = @domain.transfer_code

    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }

    @domain.reload
    refute_equal @domain.transfer_code, @old_transfer_code
  end

  def test_notifies_old_registrar
    @old_registrar = @domain.registrar

    assert_difference -> { @old_registrar.notifications.count } do
      post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_duplicates_registrant_admin_and_tech_contacts
    assert_difference -> { @new_registrar.contacts.size }, 3 do
      post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_reuses_identical_contact
    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_equal 1, @new_registrar.contacts.where(name: 'William').size
  end

  def test_saves_legal_document
    assert_difference -> { @domain.legal_documents.reload.size } do
      post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_non_transferable_domain
    @domain.update!(statuses: [DomainStatus::SERVER_TRANSFER_PROHIBITED])

    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    domains(:shop).reload

    assert_equal registrars(:bestnames), domains(:shop).registrar
    assert_epp_response :object_status_prohibits_operation
  end

  def test_discarded_domain_cannot_be_transferred
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload

    assert_equal registrars(:bestnames), @domain.registrar
    assert_epp_response :object_is_not_eligible_for_transfer
  end

  def test_same_registrar
    assert_no_difference -> { @domain.transfers.size } do
      post epp_transfer_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :use_error
  end

  def test_wrong_transfer_code
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>wrong</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
        </command>
      </epp>
    XML

    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload

    assert_epp_response :invalid_authorization_information
    refute_equal @new_registrar, @domain.registrar
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>65078d5</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
  end
end
