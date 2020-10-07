require 'test_helper'

class Whois::RecordTest < ActiveSupport::TestCase
  fixtures 'whois/records'

  setup do
    @whois_record = whois_records(:one)
    @auction = auctions(:one)

    @original_disclaimer = Setting.registry_whois_disclaimer
    Setting.registry_whois_disclaimer = JSON.generate({en: 'disclaimer'})
  end

  teardown do
    Setting.registry_whois_disclaimer = @original_disclaimer
  end

  def test_reads_disclaimer_setting
    Setting.registry_whois_disclaimer = JSON.generate({en: 'test_disclaimer'})
    assert_equal Setting.registry_whois_disclaimer, Whois::Record.disclaimer
  end

  def test_updates_whois_record_from_auction_when_started
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:started])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['AtAuction'],
                    'disclaimer' => { 'en' => 'disclaimer' }}), @whois_record.json
  end

  def test_updates_whois_record_from_auction_when_no_bids
    @auction.update!(domain: 'domain.test', status: Auction.statuses[:no_bids])
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)

    assert_not Whois::Record.exists?(name: 'domain.test')
  end

  def test_updates_whois_record_from_auction_when_awaiting_payment
    @auction.update!(domain: 'domain.test',
                     status: Auction.statuses[:awaiting_payment],
                     registration_deadline: registration_deadline)
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => { 'en' => 'disclaimer' },
                    'registration_deadline' => registration_deadline.try(:to_s, :iso8601) }),
                 @whois_record.json
  end

  def test_updates_whois_record_from_auction_when_payment_received
    @auction.update!(domain: 'domain.test',
                     status: Auction.statuses[:payment_received],
                     registration_deadline: registration_deadline)
    @whois_record.update!(name: 'domain.test')
    @whois_record.update_from_auction(@auction)
    @whois_record.reload

    assert_equal ({ 'name' => 'domain.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => { 'en' => 'disclaimer' },
                    'registration_deadline' => registration_deadline.try(:to_s, :iso8601) }),
                 @whois_record.json
  end

  def registration_deadline
    Time.zone.now + 10.days
  end
end
