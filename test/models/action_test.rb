require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  setup do
    @action = actions(:contact_update)
  end

  def test_fixture_is_valid
    assert @action.valid?
  end

  def test_invalid_with_unsupported_operation
    @action.operation = 'invalid'
    assert @action.invalid?
  end

  def test_notification_key_for_contact
    assert_equal :contact_update, @action.notification_key
  end

  def test_to_non_available_contact_codes
    assert_equal [{ code: @action.contact.code, avail: 0, reason: 'in use' }],
                 @action.to_non_available_contact_codes
  end

  def test_to_non_available_contact_codes_with_missing_contact
    @action.update!(contact: nil)

    assert_equal [], @action.to_non_available_contact_codes
  end

  def test_to_non_available_contact_codes_for_bulk_action_with_missing_subaction_contact
    bulk_action = actions(:contacts_update_bulk_action)
    actions(:contact_update_subaction_one).update!(contact: nil)

    codes = bulk_action.to_non_available_contact_codes
    assert_equal 1, codes.size
    assert_equal actions(:contact_update_subaction_two).contact.code, codes.first[:code]
  end
end