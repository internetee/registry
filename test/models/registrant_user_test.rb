require 'test_helper'

class RegistrantUserTest < ActiveSupport::TestCase
  def setup
    super

    @user = RegistrantUser.new(registrant_ident: 'US-1234')
  end

  def teardown
    super
  end

  def test_domains_returns_an_list_of_domains_associated_with_a_specific_id_code
    domain_names = @user.domains.pluck(:name)
    assert_equal(3, domain_names.length)
  end

  def test_administrated_domains_returns_a_list_of_domains_that_is_smaller_than_domains
    assert_equal(2, @user.administrated_domains.count)
  end

  def test_contacts_returns_an_list_of_contacts_associated_with_a_specific_id_code
    assert_equal(1, @user.contacts.count)
  end

  def test_ident_and_country_code_helper_methods
    assert_equal('1234', @user.ident)
    assert_equal('US', @user.country_code)
  end
end
