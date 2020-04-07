require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:cash)
  end

  def test_stores_history
    @account.balance = 200

    assert_difference '@account.versions.count', 1 do
      @account.save!
    end
  end
end
