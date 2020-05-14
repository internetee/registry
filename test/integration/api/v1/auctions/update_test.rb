require 'test_helper'

class ApiV1AuctionUpdateTest < ActionDispatch::IntegrationTest
  fixtures :auctions, 'whois/records'

  setup do
    @auction = auctions(:one)
    @whois_record = whois_records(:one)
    @whois_record.update!(name: 'auction.test')

    @original_auction_api_allowed_ips_setting = ENV['auction_api_allowed_ips']
    ENV['auction_api_allowed_ips'] = '127.0.0.1'
  end

  teardown do
    ENV['auction_api_allowed_ips'] = @original_auction_api_allowed_ips_setting
  end

  def test_returns_auction_details
    assert_equal '1b3ee442-e8fe-4922-9492-8fcb9dccc69c', @auction.uuid
    assert_equal 'auction.test', @auction.domain

    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:awaiting_payment] },
          as: :json

    assert_response :ok
    assert_equal ({ 'id' => '1b3ee442-e8fe-4922-9492-8fcb9dccc69c',
                    'domain' => 'auction.test',
                    'status' => Auction.statuses[:awaiting_payment] }), ActiveSupport::JSON
                   .decode(response.body)
  end

  def test_marks_as_awaiting_payment
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:awaiting_payment] },
          as: :json
    @auction.reload
    assert @auction.awaiting_payment?
  end

  def test_sets_registration_deadline
    deadline = (Time.zone.now + 10.days).end_of_day
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:awaiting_payment],
                    registration_deadline: deadline},
          as: :json
    @auction.reload

    assert_in_delta @auction.registration_deadline, deadline, 1.second
  end

  def test_marks_as_no_bids
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:no_bids] },
          as: :json
    @auction.reload
    assert @auction.no_bids?
  end

  def test_marks_as_payment_received
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_received] },
          as: :json
    @auction.reload
    assert @auction.payment_received?
  end

  def test_marks_as_payment_not_received
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_not_received] },
          as: :json
    @auction.reload
    assert @auction.payment_not_received?
  end

  def test_marks_as_domain_not_registered
    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:domain_not_registered] },
          as: :json
    @auction.reload
    assert @auction.domain_not_registered?
  end

  def test_reveals_registration_code_when_payment_is_received
    @auction.update!(registration_code: 'auction-001',
                     status: Auction.statuses[:awaiting_payment])

    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_received] },
          as: :json

    response_json = ActiveSupport::JSON.decode(response.body)
    assert_not_nil response_json['registration_code']
  end

  def test_conceals_registration_code_when_payment_is_not_received
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_not_received] },
          as: :json

    response_json = ActiveSupport::JSON.decode(response.body)
    assert_nil response_json['registration_code']
  end

  def test_updates_whois
    travel_to Time.zone.parse('2010-07-05 10:00')
    assert_equal 'auction.test', @auction.domain
    @whois_record.update!(updated_at: '2010-07-04')

    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_received] },
          as: :json
    @whois_record.reload

    assert_equal Time.zone.parse('2010-07-05 10:00'), @whois_record.updated_at
  end

  def test_creates_whois_record_if_does_not_exist
    travel_to Time.zone.parse('2010-07-05 10:00')
    assert_equal 'auction.test', @auction.domain
    @whois_record.delete

    patch api_v1_auction_path(@auction.uuid),
          params: { status: Auction.statuses[:payment_received] },
          as: :json

    new_whois_record = Whois::Record.find_by(name: @auction.domain)
    assert_equal Time.zone.parse('2010-07-05 10:00'), new_whois_record.updated_at
    assert_equal ['PendingRegistration'], new_whois_record.json['status']
  end

  def test_inaccessible_when_ip_address_is_not_allowed
    ENV['auction_api_allowed_ips'] = ''

    patch api_v1_auction_path(@auction.uuid), params: { status: 'any' }, as: :json

    assert_response :unauthorized
  end

  def test_auction_not_found
    assert_raises ActiveRecord::RecordNotFound do
      patch api_v1_auction_path('non-existing-uuid'),
            params: { status: Auction.statuses[:no_bids] },
            as: :json
    end
  end
end
