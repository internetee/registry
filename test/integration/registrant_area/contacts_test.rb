require 'test_helper'

class RegistrantAreaContactsIntegrationTest < ApplicationIntegrationTest
  setup do
    @domain = domains(:shop)
    @registrant = users(:registrant)
    sign_in @registrant
  end

  def test_can_view_other_domain_contacts
    secondary_contact = contacts(:jane)

    visit registrant_domain_path(@domain)
    assert_text secondary_contact.name
    click_link secondary_contact.name
    assert_text @domain.name
    assert_text secondary_contact.email
  end
end
