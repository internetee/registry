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

  def test_selling_at_auction_updates_whois
    travel_to Time.zone.parse('2010-07-05 10:00')
    @whois_record = whois_records(:one)
    @whois_record.update!(name: 'new-auction.test', updated_at: '2010-07-04')
    domain_name = DNS::DomainName.new('new-auction.test')

    domain_name.sell_at_auction
    @whois_record.reload

    assert_equal Time.zone.parse('2010-07-05 10:00'), @whois_record.updated_at
  end

  def test_selling_at_auction_creates_whois_record
    travel_to Time.zone.parse('2010-07-05 10:00')
    domain_name = DNS::DomainName.new('new-auction.test')

    domain_name.sell_at_auction

    whois_record = Whois::Record.find_by(name: 'new-auction.test')
    assert whois_record

    assert_equal Time.zone.parse('2010-07-05 10:00'), whois_record.updated_at
    assert_equal Time.zone.parse('2010-07-05 10:00'), whois_record.created_at
    assert_equal ['AtAuction'], whois_record.json['status']
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
    assert_equal 'blockedäöüõ.test', blocked_domains(:idn).name
    assert DNS::DomainName.new('blocked.test').blocked?
    assert DNS::DomainName.new('blockedäöüõ.test').blocked?
    assert DNS::DomainName.new(SimpleIDN.to_ascii('blockedäöüõ.test')).blocked?
    assert_not DNS::DomainName.new('nonblocked .test').blocked?
  end

  def test_reserved
    assert_equal 'reserved.test', reserved_domains(:one).name
    assert DNS::DomainName.new('reserved.test').reserved?
    assert_not DNS::DomainName.new('unreserved.test').reserved?
  end

  def test_registered_when_domain_exists
    assert Domain.exists?(name: 'shop.test')

    domain_name = DNS::DomainName.new('shop.test')

    assert domain_name.registered?
    refute domain_name.not_registered?
  end

  def test_not_registered_when_domain_does_not_exist
    assert_not Domain.exists?(name: 'not-registered.test')

    domain_name = DNS::DomainName.new('not-registered.test')

    assert domain_name.not_registered?
    assert_not domain_name.registered?
  end

  def test_auctionable_when_not_blocked_or_reserved
    domain_name = DNS::DomainName.new('shop.test')
    assert_not domain_name.blocked?
    assert_not domain_name.reserved?

    assert domain_name.auctionable?
  end

  def test_not_auctionable_when_blocked
    assert_equal 'blocked.test', blocked_domains(:one).name
    assert_not DNS::DomainName.new('blocked.test').auctionable?
  end

  def test_not_auctionable_when_reserved
    assert_equal 'reserved.test', reserved_domains(:one).name
    assert_not DNS::DomainName.new('reserved.test').auctionable?
  end
end
