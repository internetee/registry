require 'test_helper'

class WhoisRemoveDuplicatesTaskTest < ActiveSupport::TestCase
  fixtures 'whois/records'

  setup do
    # Duplicates can only exist without the unique index; DDL is rolled back with the test
    Whois::Record.connection.remove_index :whois_records, name: 'index_domains_on_name'
    Whois::Record.delete_all

    @single = Whois::Record.create!(name: 'single.test', json: {})
    @stale = Whois::Record.create!(name: 'duplicate.test', json: { status: 'stale' },
                                   updated_at: 2.days.ago)
    @current = Whois::Record.create!(name: 'duplicate.test', json: { status: 'current' },
                                     updated_at: 1.hour.ago)
    @older = Whois::Record.create!(name: 'duplicate.test', json: { status: 'older' },
                                   updated_at: 1.day.ago)
  end

  teardown do
    ENV.delete('DRY_RUN')
  end

  def test_only_lists_duplicates_by_default
    assert_no_difference -> { Whois::Record.count } do
      output = run_task

      assert_match(/^duplicate\.test: 3 records, keeping ##{@current.id} /, output)
      assert_match(/would delete ##{@stale.id} .*status: stale\) - differs in: status/, output)
      assert_match(/would delete ##{@older.id} /, output)
      assert_match(/1 names have more than one whois server record, 2 extra records/, output)
      assert_no_match(/single\.test/, output)
    end
  end

  def test_tells_identical_duplicates_from_stale_ones
    @older.update_columns(json: @current.json)
    output = run_task

    assert_match(/would delete ##{@older.id} .* - same data as the kept one/, output)
    assert_match(/1  same data as the kept record/, output)
    assert_match(/1  different \(older\) data than the kept record/, output)
  end

  def test_keeps_most_recently_updated_record_when_dry_run_is_disabled
    ENV['DRY_RUN'] = 'false'
    run_task

    assert_equal [@current.id], Whois::Record.where(name: 'duplicate.test').ids
    assert Whois::Record.exists?(@single.id)
  end

  def test_moves_contact_requests_to_kept_record
    ENV['DRY_RUN'] = 'false'
    contact_request = ContactRequest.save_record(whois_record_id: @stale.id,
                                                 email: 'john@inbox.test', name: 'John')
    run_task

    assert_equal @current.id, contact_request.reload.whois_record_id
  end

  private

  def run_task
    capture_io { Rake::Task['whois:remove_duplicates'].execute }.first
  end
end
