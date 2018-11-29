require 'test_helper'

class ApiV1AuctionUpdateTest < ActionDispatch::IntegrationTest
  fixtures :auctions, 'whois/records'

  setup do
    @auction = auctions(:one)

    @original_auction_api_allowed_ips_setting = ENV['auction_api_allowed_ips']
    ENV['auction_api_allowed_ips'] = '127.0.0.1'
  end

  teardown do
    ENV['auction_api_allowed_ips'] = @original_auction_api_allowed_ips_setting
  end

  def test_returns_auction_details
    assert_equal '1b3ee442-e8fe-4922-9492-8fcb9dccc69c', @auction.uuid
    assert_equal 'auction.test', @auction.domain

    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:awaiting_payment] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s

    assert_response :ok
    assert_equal ({ 'id' => '1b3ee442-e8fe-4922-9492-8fcb9dccc69c',
                    'domain' => 'auction.test',
                    'status' => Auction.statuses[:awaiting_payment] }), ActiveSupport::JSON
                                                                          .decode(response.body)
  end

  def test_marks_as_awaiting_payment
    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:awaiting_payment] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s
    @auction.reload
    assert @auction.awaiting_payment?
  end

  def test_marks_as_no_bids
    assert_equal 'auction.test', @auction.domain
    whois_records(:one).update!(name: 'auction.test')

    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:no_bids] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s
    @auction.reload
    assert @auction.no_bids?
  end

  def test_marks_as_payment_received
    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:payment_received] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s
    @auction.reload
    assert @auction.payment_received?
  end

  def test_marks_as_payment_not_received
    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:payment_not_received] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s
    @auction.reload
    assert @auction.payment_not_received?
  end

  def test_reveals_registration_code_when_payment_is_received
    @auction.update!(registration_code: 'auction-001',
                     status: Auction.statuses[:awaiting_payment])

    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:payment_received] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s

    response_json = ActiveSupport::JSON.decode(response.body)
    assert_not_nil response_json['registration_code']
  end

  def test_conceals_registration_code_when_payment_is_not_received
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:payment_not_received] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s

    response_json = ActiveSupport::JSON.decode(response.body)
    assert_nil response_json['registration_code']
  end

  def test_restarts_an_auction_when_the_payment_is_not_received
    @auction.update!(domain: 'auction.test', status: Auction.statuses[:awaiting_payment])

    patch api_v1_auction_path(@auction.uuid), { status: Auction.statuses[:payment_not_received] }
                                                .to_json, 'Content-Type' => Mime::JSON.to_s

    assert DNS::DomainName.new('auction.test').at_auction?
  end

  def test_inaccessible_when_ip_address_is_not_allowed
    ENV['auction_api_allowed_ips'] = ''

    patch api_v1_auction_path(@auction.uuid), { status: 'any' }.to_json,
          'Content-Type' => Mime::JSON.to_s

    assert_response :unauthorized
  end
end
