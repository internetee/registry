require 'test_helper'

class DomainAuditTest < ActiveSupport::TestCase

  def setup
    super

    @domain = domains(:shop)
    @contacts = @domain.contacts
    @user = users(:registrant)
  end

  def teardown
    super
  end

  def test_audit_saves_children
    duplicate_domain = prepare_duplicate_domain
    duplicate_domain.save!

    assert_equal duplicate_domain.children, duplicate_domain.versions.last.children

    admin_contact_ids = duplicate_domain.children['admin_contacts']
    admin_contacts = Contact.objects_for(admin_contact_ids)

    assert_equal duplicate_domain.admin_contacts.to_a, admin_contacts.to_a
  end

  def test_audit_saves_versions
    duplicate_domain = prepare_duplicate_domain
    assert_difference 'duplicate_domain.versions.count', 1 do
      duplicate_domain.save!
    end
  end

  private

  def prepare_duplicate_domain
    duplicate_domain = @domain.dup
    duplicate_domain.tech_contacts << @contacts
    duplicate_domain.admin_contacts << @contacts
    duplicate_domain.name = 'duplicate.test'
    duplicate_domain.uuid = nil

    duplicate_domain
  end
end
