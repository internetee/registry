require 'test_helper'

class AccountActivityTest < ActiveSupport::TestCase
  setup do
    @account_activity = account_activities(:one)
  end

  def test_fixture_is_valid
    assert @account_activity.valid?
  end

  def test_stores_history
    @account_activity.description = 'Test description'

    assert_difference '@account_activity.versions.count', 1 do
      @account_activity.save!
    end
  end
end
