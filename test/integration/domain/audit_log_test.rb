require 'test_helper'

class DomainAuditLogTest < ActionDispatch::IntegrationTest
  def test_stores_metadata
    domain = domains(:shop)
    assert_equal [contacts(:jane).id], domain.admin_contacts.ids
    assert_equal [contacts(:william).id, contacts(:acme_ltd).id].sort, domain.tech_contacts.ids.sort
    assert_equal [nameservers(:shop_ns1).id, nameservers(:shop_ns2).id].sort, domain.nameservers.ids
                                                                                .sort
    assert_equal contacts(:john).id, domain.registrant_id

    domain.legal_document_id = 1
    assert_difference 'domain.versions.count' do
      domain.save!
    end

    domain_version = domain.versions.last
    assert_equal ({ admin_contacts: [contacts(:jane).id],
                    tech_contacts: [contacts(:william).id, contacts(:acme_ltd).id],
                    nameservers: [nameservers(:shop_ns1).id, nameservers(:shop_ns2).id],
                    dnskeys: [],
                    legal_documents: [1],
                    registrant: [contacts(:john).id] }).with_indifferent_access,
                 domain_version.children.with_indifferent_access
  end
end