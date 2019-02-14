require 'test_helper'

class ApiV1AuctionListTest < ActionDispatch::IntegrationTest
  setup do
    @auction = auctions(:one)
  end

  def test_returns_started_auctions_without_authentication
    @auction.update!(uuid: '1b3ee442-e8fe-4922-9492-8fcb9dccc69c',
                     domain: 'auction.test',
                     status: Auction.statuses[:started])

    get api_v1_auctions_path, nil, 'Content-Type' => Mime::JSON.to_s

    assert_response :ok
    assert_equal ([{ 'id' => '1b3ee442-e8fe-4922-9492-8fcb9dccc69c',
                     'domain' => 'auction.test',
                     'status' => Auction.statuses[:started] }]), ActiveSupport::JSON
                                                                   .decode(response.body)
  end

  def test_does_not_return_finished_auctions
    @auction.update!(domain: 'auction.test', status: Auction.statuses[:awaiting_payment])

    get api_v1_auctions_path, nil, 'Content-Type' => Mime::JSON.to_s

    assert_response :ok
    assert_empty ActiveSupport::JSON.decode(response.body)
  end
end
