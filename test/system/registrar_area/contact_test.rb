require 'application_system_test_case'

class RegistrarAreaContactTest < ApplicationSystemTestCase
  setup do
    @registrar = registrars(:bestnames)
    @contact = contacts(:john)
    sign_in users(:api_bestnames)
  end

  def test_creates_contact_with_invalid_phone
    visit registrar_contacts_path
    click_on 'New'

    fill_in 'Ident', with: @contact.ident
    fill_in 'Name', with: @contact.name
    fill_in 'E-mail', with: @contact.email
    fill_in 'Phone', with: '372'
    click_on 'Create'

    assert_text 'Phone number must be in +XXX.YYYYYYY format'
  end

  def test_updates_contact_with_invalid_phone
    depp_contact = Depp::Contact.new(
      id: @contact.id,
      name: @contact.name,
      code: @contact.code,
      email: @contact.email,
      phone: @contact.phone,
      ident: @contact.ident,
      ident_type: @contact.ident_type,
      ident_country_code: @contact.ident_country_code)

    Spy.on(Depp::Contact, :find_by_id).and_return(depp_contact)

    visit edit_registrar_contact_path(depp_contact.code)

    assert_text "Edit: #{depp_contact.name}"

    fill_in 'Phone', with: '372'
    click_on 'Save'

    assert_text 'Phone number must be in +XXX.YYYYYYY format'
  end
end
