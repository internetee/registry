require 'application_system_test_case'

class RegistrantDomainsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:registrant)
  end

  def test_shows_domains_where_current_user_is_registrant
    visit registrant_domains_url
    assert_text 'shop.test'
  end

  def test_shows_domains_where_current_user_is_contact_person
    visit registrant_domains_url
    assert_text 'airport.test'
  end

  def test_shows_domains_where_current_user_has_associated_organizations
    visit registrant_domains_url
    assert_text 'library.test'
  end
end
