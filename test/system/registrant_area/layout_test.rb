require 'test_helper'

class RegistrantLayoutTest < ApplicationSystemTestCase
  def setup
    super
    sign_in(users(:registrant))
  end

  def test_has_link_to_rest_whois_and_internet_ee
    visit registrant_domains_url

    assert(has_link?('Internet.ee', href: 'https://internet.ee'))
    assert(has_link?('WHOIS', href: 'https://whois.internet.ee'))
  end
end
