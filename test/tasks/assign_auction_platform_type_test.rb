require 'test_helper'

class AssignAuctionPlatformTypeTest < ActiveSupport::TestCase
  setup do
    @auction_one = auctions(:one)
    @auction_two = auctions(:idn)
  end

  def test_output
    assert_nil @auction_one.platform
    assert_nil @auction_two.platform

    run_task

    @auction_one.reload
    @auction_two.reload

    assert_equal @auction_one.platform, "auto"
    assert_equal @auction_two.platform, "auto"
  end

  private

  def run_task
    Rake::Task['auction:assign_platform_type'].execute
  end
end
