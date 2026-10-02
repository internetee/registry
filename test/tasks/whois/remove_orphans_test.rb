require 'test_helper'

class WhoisRemoveOrphansTaskTest < ActiveSupport::TestCase
  fixtures 'whois/records'

  setup do
    @domain = domains(:shop)
    Whois::Record.delete_all
    @live_record = Whois::Record.create!(name: @domain.name, json: { name: @domain.name })
    @orphan = Whois::Record.create!(name: 'orphan.test',
                                    json: { name: 'orphan.test', status: ['serverHold'] })
  end

  teardown do
    ENV.delete('DRY_RUN')
  end

  def test_only_lists_orphans_by_default
    assert_no_difference -> { Whois::Record.count } do
      assert_match(/orphan\.test/, run_task)
    end
  end

  def test_deletes_orphans_when_dry_run_is_disabled
    ENV['DRY_RUN'] = 'false'
    run_task

    assert_not Whois::Record.exists?(@orphan.id)
    assert Whois::Record.exists?(@live_record.id)
  end

  def test_keeps_record_of_pending_auction
    ENV['DRY_RUN'] = 'false'
    auctions(:one).update!(domain: 'orphan.test', status: Auction.statuses[:started])
    run_task

    assert Whois::Record.exists?(@orphan.id)
  end

  def test_keeps_record_when_name_differs_only_by_case
    ENV['DRY_RUN'] = 'false'
    @live_record.update!(name: @domain.name.upcase)
    run_task

    assert Whois::Record.exists?(@live_record.id)
  end

  private

  def run_task
    capture_io { Rake::Task['whois:remove_orphans'].execute }.first
  end
end
