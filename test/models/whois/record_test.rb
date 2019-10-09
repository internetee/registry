require 'test_helper'

class Whois::RecordTest < ActiveSupport::TestCase
  fixtures 'whois/records'

  setup do
    @whois_record = whois_records(:one)
    @auction = auctions(:one)

    @original_disclaimer = Setting.registry_whois_disclaimer
    Setting.registry_whois_disclaimer = 'disclaimer'
  end

  teardown do
    Setting.registry_whois_disclaimer = @original_disclaimer
  end

  def test_reads_disclaimer_setting
    Setting.registry_whois_disclaimer = 'test disclaimer'
    assert_equal 'test disclaimer', Whois::Record.disclaimer
  end

  def test_updates_whois_record_from_auction_when_started
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:started])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['AtAuction'],
                    'disclaimer' => 'disclaimer' }), @whois_record.json
  end

  def test_updates_whois_record_from_auction_when_no_bids
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:no_bids])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)

    assert_not Whois::Record.exists?(name: 'domain.test')
  end

  def test_updates_whois_record_from_auction_when_awaiting_payment
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:awaiting_payment])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => 'disclaimer' }), @whois_record.json
  end

  def test_updates_whois_record_from_auction_when_payment_received
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:payment_received])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => 'disclaimer' }), @whois_record.json
  end
end