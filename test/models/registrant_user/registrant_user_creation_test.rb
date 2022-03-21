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

  def test_updates_related_contacts_name_if_different_from_e_identity
    registrars = [registrars(:bestnames), registrars(:goodnames)]
    contacts = [contacts(:john), contacts(:william), contacts(:identical_to_william)]
    contacts.each do |c|
      c.update(ident: '39708290276', ident_country_code: 'EE')
    end

    user_data = {
      ident: '39708290276',
      first_name: 'John',
      last_name: 'Doe',
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-39708290276')
    assert_equal('John Doe', user.username)

    contacts.each do |c|
      c.reload
      assert_equal user.username, c.name
      assert user.actions.find_by(operation: :update, contact_id: c.id)
    end

    bulk_action = BulkAction.find_by(user_id: user.id, operation: :bulk_update)
    assert_equal 2, bulk_action.subactions.size

    registrars.each do |r|
      notification = r.notifications.unread.order('created_at DESC').take
      if r == registrars(:bestnames)
        assert_equal '2 contacts have been updated by registrant', notification.text
        assert_equal 'BulkAction', notification.attached_obj_type
        assert_equal bulk_action.id, notification.attached_obj_id
        assert_equal bulk_action.id, notification.action_id
      else
        assert_equal 'Contact william-002 has been updated by registrant', notification.text
        refute notification.action_id
        refute notification.attached_obj_id
        refute notification.attached_obj_type
      end
    end
  end
end
