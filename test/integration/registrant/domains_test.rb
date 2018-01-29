require 'test_helper'

class RegistrantDomainsTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:registrant)

    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
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
