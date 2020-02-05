require 'test_helper'

class DomainAuditLogTest < ActionDispatch::IntegrationTest
  def test_stores_metadata
    domain = domains(:shop)
    admin_contact_ids = [contacts(:jane).id].sort
    tech_contact_ids = [contacts(:william).id, contacts(:acme_ltd).id].sort
    nameserver_ids = [nameservers(:shop_ns1).id, nameservers(:shop_ns2).id].sort
    registrant_id = contacts(:john).id
    legal_document_id = 1
    assert_equal admin_contact_ids, domain.admin_contacts.ids
    assert_equal tech_contact_ids, domain.tech_contacts.ids.sort
    assert_equal nameserver_ids, domain.nameservers.ids.sort
    assert_equal registrant_id, domain.registrant_id
    domain.legal_document_id = legal_document_id

    assert_difference 'domain.versions.count', 2 do
      domain.save!
    end

    domain_version = domain.versions.last
    assert_equal admin_contact_ids, domain_version.children['admin_contacts'].sort
    assert_equal tech_contact_ids, domain_version.children['tech_contacts'].sort
    assert_equal nameserver_ids, domain_version.children['nameservers'].sort
    assert_equal [], domain_version.children['dnskeys']
    assert_equal [legal_document_id], domain_version.children['legal_documents']
    assert_equal [registrant_id], domain_version.children['registrant']
  end
end
