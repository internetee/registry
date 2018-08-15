require 'test_helper'

class RegistrantAreaDomainListTest < ApplicationSystemTestCase
  setup do
    sign_in users(:registrant)
    @domain = domains(:shop)

    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
  end

  def test_show_domain_list
    visit registrant_domains_url
    assert_link 'shop.test', href: registrant_domain_path(@domain)
    assert_link 'John', href: registrant_domain_contact_path(@domain, @domain.registrant)
    assert_link 'Best Names', href: registrant_registrar_path(@domain.registrar)
    assert_text l(Time.zone.parse('2010-07-05'))
    assert_css '.domains .domain', count: 5
  end
end