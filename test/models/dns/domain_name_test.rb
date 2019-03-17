require 'test_helper'

class AuctionDouble
  def domain_registrable?(_code)
    true
  end
end

class AuctionDoubleTest < ActiveSupport::TestCase
  def test_implements_the_domain_registrable_interface
    assert_respond_to AuctionDouble.new, :domain_registrable?
  end
end

class DNS::DomainNameTest < ActiveSupport::TestCase
  def test_available_when_not_at_auction
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:domain_registered])

    assert domain_name.available?
    assert_not domain_name.unavailable?
  end

  def test_available_with_correct_code
    domain_name = DNS::DomainName.new('auction.test')

    Auction.stub(:pending, AuctionDouble.new) do
      assert domain_name.available_with_code?('some')
    end
  end

  def test_unavailable_when_registered
    domain_name = DNS::DomainName.new('shop.test')
    assert_equal 'shop.test', domains(:shop).name

    assert domain_name.unavailable?
    assert_equal :registered, domain_name.unavailability_reason
  end

  def test_unavailable_when_blocked
    domain_name = DNS::DomainName.new('blocked.test')
    assert_equal 'blocked.test', blocked_domains(:one).name

    assert domain_name.unavailable?
    assert_equal :blocked, domain_name.unavailability_reason
  end

  def test_unavailable_when_zone_with_the_same_origin_exists
    domain_name = DNS::DomainName.new('test')
    assert_equal 'test', dns_zones(:one).origin

    assert domain_name.unavailable?
    assert_equal :zone_with_same_origin, domain_name.unavailability_reason
  end

  def test_unavailable_when_at_auction
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:started])

    assert domain_name.unavailable?
    assert_not domain_name.available?
    assert_equal :at_auction, domain_name.unavailability_reason
  end

  def test_unavailable_when_awaiting_payment
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:awaiting_payment])

    assert domain_name.unavailable?
    assert_not domain_name.available?
    assert_equal :awaiting_payment, domain_name.unavailability_reason
  end

  def test_sells_at_auction
    domain_name = DNS::DomainName.new('shop.test')
    assert_not domain_name.at_auction?

    domain_name.sell_at_auction

    assert domain_name.at_auction?
  end

  def test_at_auction
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:started])
    assert domain_name.at_auction?
  end

  def test_awaiting_payment
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:awaiting_payment])
    assert domain_name.awaiting_payment?
  end

  def test_pending_registration
    domain_name = DNS::DomainName.new('auction.test')
    auctions(:one).update!(domain: 'auction.test', status: Auction.statuses[:payment_received])
    assert domain_name.pending_registration?
  end

  def test_to_s
    domain_name = DNS::DomainName.new('shop.test')
    assert_equal 'shop.test', domain_name.to_s
  end

  def test_blocked
    assert_equal 'blocked.test', blocked_domains(:one).name
    assert DNS::DomainName.new('blocked.test').blocked?
    assert_not DNS::DomainName.new('nonblocked .test').blocked?
  end

  def test_reserved
    assert_equal 'reserved.test', reserved_domains(:one).name
    assert DNS::DomainName.new('reserved.test').reserved?
    assert_not DNS::DomainName.new('unreserved.test').reserved?
  end

  def test_updates_whois_from_auction
    auction = 'auction'
    whois_record_mock = Minitest::Mock.new
    whois_record_mock.expect(:update_from_auction, nil, [auction])
    domain_name = DNS::DomainName.new('domain.test', whois_record_mock)

    domain_name.update_whois_from_auction(auction)

    whois_record_mock.verify
  end
end