require 'test_helper'

class ContactAuditLogTest < ActionDispatch::IntegrationTest
  def test_stores_metadata
    contact = contacts(:john)

    contact.legal_document_id = 1
    assert_difference 'contact.versions.count', 2 do
      contact.save!
    end

    contact_version = contact.versions.last
    assert_equal ({ legal_documents: [1] }).with_indifferent_access,
                 contact_version.children.with_indifferent_access
  end
end
