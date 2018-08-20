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
end