require 'test_helper'

class ContactAuditTest < ActiveSupport::TestCase

  def test_audit_returns_versions
    contact = contacts(:john)
    old_contact = contact
    contact.legal_document_ids << 1
    contact.save!

    history_objects = Contact.objects_for([contact.id])
    assert_equal history_objects, [old_contact]
  end

  def test_audit_stores_updator
    contact = contacts(:john)
    contact.legal_document_ids << 1
    contact.save!

    assert contact.updator.present?
  end

  def test_stores_audit_data
    contact = contacts(:john)
    contact.legal_document_ids << 1

    assert_difference 'contact.versions.count', 1 do
      contact.save!
    end
  end
end
