require 'test_helper'

class RegistrantUserCreationTest < ActiveSupport::TestCase
  def test_find_or_create_by_api_data_creates_a_user
    user_data = {
      ident: '37710100070',
      first_name: 'JOHN',
      last_name: 'SMITH'
    }
    assert_difference 'RegistrantUser.count' do
      RegistrantUser.find_or_create_by_api_data(user_data)
    end

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_api_data_updates_a_user_with_existing_ident
    user_data = {
      ident: '1234',
      country_code: 'US',
      first_name: 'John',
      last_name: 'Smith',
    }
    assert_no_difference 'RegistrantUser.count' do
      RegistrantUser.find_or_create_by_api_data(user_data)
    end

    user = User.find_by(registrant_ident: 'US-1234')
    assert_equal('John Smith', user.username)
  end
end
