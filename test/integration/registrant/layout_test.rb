require 'test_helper'

class RegistrantLayoutTest < ActionDispatch::IntegrationTest
  def setup
    super
    login_as(users(:registrant))

    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
  end

  def test_has_link_to_rest_whois_and_internet_ee
    visit registrant_domains_url

    assert(has_link?('Internet.ee', href: 'https://internet.ee'))
    assert(has_link?('WHOIS', href: 'https://whois.internet.ee'))
  end
end
