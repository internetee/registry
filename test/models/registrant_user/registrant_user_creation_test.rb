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

  def test_find_or_create_by_api_data_creates_a_user_after_upcasing_input
    user_data = {
      ident: '37710100070',
      first_name: 'John',
      last_name: 'Smith'
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_mid_data_creates_a_user
    user_data = OpenStruct.new(user_country: 'EE', user_id_code: '37710100070',
                               user_givenname: 'JOHN', user_surname: 'SMITH')

    RegistrantUser.find_or_create_by_mid_data(user_data)
    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end
end
