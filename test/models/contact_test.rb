require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_valid_fixture_is_valid
    assert @contact.valid?, proc { @contact.errors.full_messages }
  end

  def test_invalid_fixture_is_invalid
    assert contacts(:invalid).invalid?
  end

  def test_private_entity
    assert_equal 'priv', Contact::PRIV
  end

  def test_legal_entity
    assert_equal 'org', Contact::ORG
  end

  def test_invalid_without_email
    @contact.email = ''
    assert @contact.invalid?
  end

  def test_email_format_validation
    @contact.email = 'invalid'
    assert @contact.invalid?

    @contact.email = 'test@bestmail.test'
    assert @contact.valid?
  end

  def test_invalid_without_phone
    @contact.email = ''
    assert @contact.invalid?
  end

  def test_phone_format_validation
    @contact.phone = '+123.'
    assert @contact.invalid?

    @contact.phone = '+123.4'
    assert @contact.valid?
  end

  def test_address
    address = Contact::Address.new('new street', '83746', 'new city', 'new state', 'EE')
    @contact.address = address
    @contact.save!
    @contact.reload

    assert_equal 'new street', @contact.street
    assert_equal '83746', @contact.zip
    assert_equal 'new city', @contact.city
    assert_equal 'new state', @contact.state
    assert_equal 'EE', @contact.country_code
    assert_equal address, @contact.address
  end

  def test_returns_registrant_user_direct_contacts
    assert_equal Contact::PRIV, @contact.ident_type
    assert_equal '1234', @contact.ident
    assert_equal 'US', @contact.ident_country_code
    registrant_user = RegistrantUser.new(registrant_ident: 'US-1234')

    registrant_user.stub(:companies, []) do
      assert_equal [@contact], Contact.registrant_user_contacts(registrant_user)
      assert_equal [@contact], Contact.registrant_user_direct_contacts(registrant_user)
    end
  end

  def test_returns_registrant_user_indirect_contacts
    @contact.update!(ident_type: Contact::ORG)
    assert_equal '1234', @contact.ident
    assert_equal 'US', @contact.ident_country_code
    registrant_user = RegistrantUser.new(registrant_ident: 'US-1234')

    registrant_user.stub(:companies, [OpenStruct.new(registration_number: '1234')]) do
      assert_equal [@contact], Contact.registrant_user_contacts(registrant_user)
    end
  end

  def test_contact_is_a_registrant
    assert_equal @contact.becomes(Registrant), domains(:shop).registrant
    assert @contact.registrant?

    make_contact_free_of_domains_where_it_acts_as_a_registrant(@contact)
    assert_not @contact.registrant?
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

  def test_deletable_when_not_linked
    contact = unlinked_contact
    assert contact.deletable?
  end

  def test_undeletable_when_linked
    assert @contact.linked?
    assert_not @contact.deletable?
  end

  private

  def make_contact_free_of_domains_where_it_acts_as_a_registrant(contact)
    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact)
  end

  def unlinked_contact
    Domain.update_all(registrant_id: contacts(:william))
    DomainContact.delete_all
    contacts(:john)
  end
end