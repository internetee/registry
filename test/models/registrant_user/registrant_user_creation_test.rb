require 'test_helper'

class RegistrantUserCreationTest < ActiveSupport::TestCase
  def test_find_or_create_by_api_data_creates_a_user
    user_data = {
      ident: '37710100070',
      first_name: 'JOHN',
      last_name: 'SMITH'
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_api_data_creates_a_user_with_original_name
    user_data = {
      ident: '37710100070',
      first_name: 'John',
      last_name: 'Smith'
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('John Smith', user.username)
  end

  def test_updates_related_contacts_name_if_differs_from_e_identity
    contact = contacts(:john)
    contact.update(ident: '39708290276', ident_country_code: 'EE')

    user_data = {
      ident: '39708290276',
      first_name: 'John',
      last_name: 'Doe'
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-39708290276')
    assert_equal('John Doe', user.username)

    contact.reload
    assert_equal user.username, contact.name
  end

  def test_update_contact_to_company_name
    contact = contacts(:john)
    registrant_user = RegistrantUser.first
    company = CompanyRegister::Client.new.representation_rights(
      citizen_personal_code: registrant_user.ident,
      citizen_country_code: registrant_user.country.alpha3
    ).first

    contact.ident = company.registration_number
    contact.ident_country_code = 'EE'
    contact.save(validate: false)

    registrant_user.companies
    poll_message = contact.registrar.notifications.last.text

    assert_equal(
      'Contact update: john-001 name updated from John to ACME Ltd by the registry',
      poll_message
    )
  end
end
