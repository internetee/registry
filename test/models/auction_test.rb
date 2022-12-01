require 'test_helper'

class AuctionTest < ActiveSupport::TestCase
  setup do
    @auction = auctions(:one)
  end

  def test_fixture_is_valid
    assert @auction.valid?
  end

  def test_statuses
    assert_equal ({ 'started' => 'started',
                    'no_bids' => 'no_bids',
                    'awaiting_payment' => 'awaiting_payment',
                    'payment_received' => 'payment_received',
                    'payment_not_received' => 'payment_not_received',
                    'domain_registered' => 'domain_registered',
                    'domain_not_registered' => 'domain_not_registered' }), Auction.statuses
  end

  def test_starts_an_auction
    assert_not @auction.started?

    @auction.start
    @auction.reload

    assert @auction.started?
  end

  def test_auction_with_no_bids_dont_have_any_restriction
    @auction.update(status: :no_bids)
    @auction.reload

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(@auction.domain)
    refute res
  end

  def test_auction_with_domain_registered_dont_have_any_restriction
    @auction.update(status: :domain_registered)
    @auction.reload

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(@auction.domain)
    refute res
  end

  def test_auction_with_started_has_restriction
    @auction.update(status: :started)
    @auction.reload

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(@auction.domain)
    assert res
  end

  def test_blocked_domain_has_restriction
    blocked_domain = blocked_domains(:one)

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(blocked_domain.name)
    assert res
  end

  def test_dispute_domain_has_restriction
    dispute_domain = disputes(:active)

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(dispute_domain.domain_name)
    assert res
  end

  def test_exist_domain_has_restriction
    domain = domains(:shop)

    res = Auction.domain_exists_in_blocked_disputed_and_registered?(domain.name)
    assert res
  end

  def test_pending
    domain_name = DNS::DomainName.new('auction.test')
    assert_equal 'auction.test', @auction.domain

    assert @auction.no_bids?
    assert_nil Auction.pending(domain_name)

    @auction.update!(status: Auction.statuses[:started])
    assert_equal @auction, Auction.pending(domain_name)

    @auction.update!(status: Auction.statuses[:awaiting_payment])
    assert_equal @auction, Auction.pending(domain_name)

    @auction.update!(status: Auction.statuses[:payment_received])
    assert_equal @auction, Auction.pending(domain_name)
  end

  def test_record_with_invalid_status_cannot_be_saved
    # ArgumentError is triggered by ActiveRecord::Base.enum
    assert_raises ArgumentError do
      @auction.status = 'invalid'
      @auction.save!
    end
  end

  def test_marking_as_no_bids
    @auction.update!(status: Auction.statuses[:started])

    @auction.mark_as_no_bids
    @auction.reload

    assert @auction.no_bids?
  end

  def test_marking_as_payment_received
    @auction.update!(status: Auction.statuses[:awaiting_payment], registration_code: nil)

    @auction.mark_as_payment_received
    @auction.reload

    assert @auction.payment_received?
    assert_not_nil @auction.registration_code
  end

  def test_marking_as_payment_not_received
    @auction.update!(status: Auction.statuses[:awaiting_payment], registration_code: nil)

    @auction.mark_as_payment_not_received
    @auction.reload

    assert @auction.payment_not_received?
    assert_nil @auction.registration_code
  end

  def test_marking_as_payment_not_received_restarts_an_auction
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    assert_difference 'Auction.count' do
      @auction.mark_as_payment_not_received
    end
  end

  def test_marking_as_domain_not_registered
    @auction.update!(status: Auction.statuses[:payment_received])

    @auction.mark_as_domain_not_registered
    @auction.reload

    assert @auction.domain_not_registered?
  end

  def test_marking_as_domain_not_registered_restarts_an_auction
    @auction.update!(status: Auction.statuses[:payment_received])

    assert_difference 'Auction.count' do
      @auction.mark_as_domain_not_registered
    end
  end

  def test_domain_registrable
    assert @auction.no_bids?
    assert_not @auction.domain_registrable?

    @auction.status = Auction.statuses[:payment_received]
    @auction.registration_code = 'auction001'

    assert @auction.domain_registrable?('auction001')
  end

  def test_domain_unregistrable
    @auction.status = Auction.statuses[:payment_not_received]
    @auction.registration_code = 'auction001'

    assert_not @auction.domain_registrable?('auction001')

    @auction.status = Auction.statuses[:payment_received]
    @auction.registration_code = 'auction001'

    assert_not @auction.domain_registrable?('wrong')
    assert_not @auction.domain_registrable?(nil)
    assert_not @auction.domain_registrable?('')
  end

  def test_restart_new_auction_should_with_previous_manual_platform
    @auction.update(platform: 'manual')
    @auction.reload

    assert_equal @auction.platform, 'manual'

    assert_difference 'Auction.count' do
      @auction.restart
    end

    new_auction = Auction.last
    assert_equal new_auction.platform, 'manual'
  end

  def test_restart_new_auction_should_with_previous_auto_platform
    @auction.update(platform: 'auto')
    @auction.reload

    assert_equal @auction.platform, 'auto'

    assert_difference 'Auction.count' do
      @auction.restart
    end

    new_auction = Auction.last
    assert_equal new_auction.platform, 'auto'
  end

  def test_restart_new_auction_should_with_auto_if_platform_is_nil
    @auction.update(platform: nil)
    @auction.reload

    assert_nil @auction.platform

    assert_difference 'Auction.count' do
      @auction.restart
    end

    new_auction = Auction.last
    assert_equal new_auction.platform, 'auto'
  end


  def test_restarts_an_auction
    assert_equal 'auction.test', @auction.domain

    assert_difference 'Auction.count' do
      @auction.restart
    end

    new_auction = Auction.last
    assert_equal 'auction.test', new_auction.domain
    assert new_auction.started?
  end

  def test_auction_restart_should_assign_the_previous_manual_platform
    assert_equal 'auction.test', @auction.domain
    @auction.update(platform: :manual)
    @auction.reload

    assert_difference 'Auction.count' do
      @auction.restart
    end

    auctions = Auction.where(domain: @auction.domain)
    assert_equal auctions.first.platform, auctions.last.platform
  end

  def test_auction_restart_should_assign_the_previous_auto_platform
    assert_equal 'auction.test', @auction.domain
    @auction.update(platform: :auto)
    @auction.reload

    assert_difference 'Auction.count' do
      @auction.restart
    end

    auctions = Auction.where(domain: @auction.domain)
    assert_equal auctions.first.platform, auctions.last.platform
  end
end