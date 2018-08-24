require 'test_helper'

class RegistrantUserTest < ActiveSupport::TestCase
  def setup
    super

    @user = users(:registrant)
  end

  def teardown
    super
  end

  def test_domains_returns_an_list_of_distinct_domains_associated_with_a_specific_id_code
    domain_names = @user.domains.pluck(:name)
    assert_equal(3, domain_names.length)

    # User is a registrant, but not a contact for the domain.
    refute(domain_names.include?('shop.test'))
  end

  def test_administrated_domains_returns_a_list_of_domains
    domain_names = @user.administrated_domains.pluck(:name)
    assert_equal(3, domain_names.length)

    # User is a tech contact for the domain.
    refute(domain_names.include?('library.test'))
  end

  def test_contacts_returns_an_list_of_contacts_associated_with_a_specific_id_code
    assert_equal(1, @user.contacts.count)
  end

  def test_ident_and_country_code_helper_methods
    assert_equal('1234', @user.ident)
    assert_equal('US', @user.country_code)
  end
end
