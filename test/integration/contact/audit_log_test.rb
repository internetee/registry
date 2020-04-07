require 'test_helper'

class ContactAuditLogTest < ActionDispatch::IntegrationTest
  def test_stores_history
    contact = contacts(:john)

    contact.legal_document_ids << 1
    assert_difference 'contact.versions.count', 1 do
      contact.save!
    end
  end
end
