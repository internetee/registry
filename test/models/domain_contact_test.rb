require 'test_helper'

class DomainContactTest < ActiveSupport::TestCase
  setup do
    @domain_contact = domain_contacts(:shop_jane)
  end

  def test_if_domain_contact_type_invalid
    @domain_contact.update(type: "Some")
    assert @domain_contact.name, ''
  end

  def test_value_typeahead
    assert @domain_contact.value_typeahead, 'Jane'
  end

  def test_validates_admin_contact_age_with_birthday
    admin_contact = contacts(:john)
    admin_contact.update!(
      ident_type: 'birthday',
      ident: (Time.zone.now - 16.years).strftime('%Y-%m-%d')
    )
    
    domain_contact = AdminDomainContact.new(
      domain: domains(:shop),
      contact: admin_contact
    )
    
    assert_not domain_contact.valid?
    assert_includes domain_contact.errors.full_messages, 
                    'Contact Administrative contact must be at least 18 years old'
  end

  def test_validates_admin_contact_age_with_estonian_id
    admin_contact = contacts(:john)
    admin_contact.update!(
      ident_type: 'priv',
      ident: '61203150222',
      ident_country_code: 'EE'
    )
    
    domain_contact = AdminDomainContact.new(
      domain: domains(:shop),
      contact: admin_contact
    )
    
    assert_not domain_contact.valid?
    assert_includes domain_contact.errors.full_messages, 
                    'Contact Administrative contact must be at least 18 years old'
  end

  def test_allows_adult_admin_contact_with_birthday
    admin_contact = contacts(:john)
    admin_contact.update!(
      ident_type: 'birthday',
      ident: (Time.zone.now - 20.years).strftime('%Y-%m-%d')
    )
    
    domain_contact = AdminDomainContact.new(
      domain: domains(:shop),
      contact: admin_contact
    )
    
    assert domain_contact.valid?
  end

  def test_allows_adult_admin_contact_with_estonian_id
    admin_contact = contacts(:john)
    admin_contact.update!(
      ident_type: 'priv',
      ident: '38903111310',
      ident_country_code: 'EE'
    )
    
    domain_contact = AdminDomainContact.new(
      domain: domains(:shop),
      contact: admin_contact
    )
    
    assert domain_contact.valid?
  end

end