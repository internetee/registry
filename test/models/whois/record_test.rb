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

  def test_whois_records_without_auction
    domain = Whois::Record.without_auctions
    assert_equal domain[0].name, 'shop.test'
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

  def test_name_is_unique_on_database_level
    assert_raises ActiveRecord::RecordNotUnique do
      Whois::Record.create!(name: @whois_record.name, json: {})
    end
  end

  def test_find_or_create_by_name_returns_existing_record_when_insert_loses_race
    lost_race = ->(*) { raise ActiveRecord::RecordNotUnique }

    Whois::Record.stub(:find_or_create_by!, lost_race) do
      assert_equal @whois_record, Whois::Record.find_or_create_by_name!(@whois_record.name)
    end
  end

  def test_save_by_name_updates_existing_record_when_insert_loses_race
    original_finder = Whois::Record.method(:find_or_initialize_by)
    calls = 0
    # First lookup misses the row, as if it was inserted by another process right after
    finder = lambda do |attributes|
      calls += 1
      calls == 1 ? Whois::Record.new(attributes) : original_finder.call(attributes)
    end

    Whois::Record.stub(:find_or_initialize_by, finder) do
      Whois::Record.save_by_name(@whois_record.name) do |record|
        record.json = { name: record.name, status: ['Blocked'] }
      end
    end

    assert_equal 1, Whois::Record.where(name: @whois_record.name).count
    assert_equal ['Blocked'], @whois_record.reload.json['status']
  end

  def registration_deadline
    @registration_deadline ||= Time.zone.now + 10.days
  end
end
