require 'application_system_test_case'

class RegistrantAreaContactDetailsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:registrant)
    @domain = domains(:shop)
    @contact = contacts(:john)
  end

  def test_general_data
    visit registrant_domain_contact_url(@domain, @contact)
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

  def test_registrant_user_cannot_access_contact_when_given_domain_belongs_to_another_user
    suppress(ActiveRecord::RecordNotFound) do
      visit registrant_domain_contact_url(domains(:metro), @contact)
      assert_response :not_found
      assert_no_text 'Name John'
    end
  end
end
