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
end
