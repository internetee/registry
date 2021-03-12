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

end