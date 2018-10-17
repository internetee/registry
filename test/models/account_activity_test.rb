require 'test_helper'

class AccountActivityTest < ActiveSupport::TestCase
  setup do
    @account_activity = account_activities(:one)
  end

  def test_fixture_is_valid
    assert @account_activity.valid?
  end
end