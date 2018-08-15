require 'test_helper'

class RegistrantAreaContactDetailsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:registrant)
    @contact = contacts(:john)

    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
  end

  def test_general_data
    visit registrant_domain_contact_url(domains(:shop), @contact)
    assert_text 'Code john-001'
    assert_text 'Name John'

    assert_text 'Auth info'
    assert_css('[value="cacb5b"]')

    assert_text 'Ident 1234'
    assert_text 'Email john@inbox.test'
    assert_text 'Phone +555.555'

    assert_text "Created at #{l Time.zone.parse('2010-07-05')}"
    assert_text "Updated at #{l Time.zone.parse('2010-07-06')}"
  end
end