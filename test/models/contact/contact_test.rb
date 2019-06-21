require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_valid_fixture_is_valid
    assert @contact.valid?
  end

  def test_invalid_fixture_is_invalid
    assert contacts(:invalid).invalid?
  end

  def test_linked_when_in_use_as_registrant
    Domain.update_all(registrant_id: @contact)
    DomainContact.delete_all

    assert @contact.linked?
  end

  def test_linked_when_in_use_as_domain_contact
    Domain.update_all(registrant_id: contacts(:william))
    DomainContact.update_all(contact_id: @contact)

    assert @contact.linked?
  end

  def test_unlinked_when_not_in_use_as_either_registrant_or_domain_contact
    contact = unlinked_contact
    assert_not contact.linked?
  end

  def test_managed_when_identity_codes_match
    contact = Contact.new(ident: '1234')
    user = RegistrantUser.new(registrant_ident: 'US-1234')
    assert contact.managed_by?(user)
  end

  def test_unmanaged_when_identity_codes_do_not_match
    contact = Contact.new(ident: '1234')
    user = RegistrantUser.new(registrant_ident: 'US-12345')
    assert_not contact.managed_by?(user)
  end

  private

  def unlinked_contact
    Domain.update_all(registrant_id: contacts(:william))
    DomainContact.delete_all
    contacts(:john)
  end
end
