require 'test_helper'

class BlockedDomainTest < ActiveSupport::TestCase
  setup do
    @blocked_domain = blocked_domains(:one)
  end

  def test_stores_history
    @blocked_domain.name = 'testäöüõ.test'

    assert_difference '@blocked_domain.versions.count', 1 do
      @blocked_domain.save!
    end
  end
end
