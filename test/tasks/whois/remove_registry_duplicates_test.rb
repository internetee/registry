require 'test_helper'

class WhoisRemoveRegistryDuplicatesTaskTest < ActiveSupport::TestCase
  setup do
    # Duplicates can only exist without the unique index; DDL is rolled back with the test
    WhoisRecord.connection.remove_index :whois_records, name: 'index_whois_records_on_domain_id'

    @domain = domains(:shop)
    @current = whois_records(:shop)
    @whois_server_record = Whois::Record.find_or_create_by_name!(@domain.name)
    @stale = insert_record(domain_id: @domain.id, name: @domain.name, updated_at: 2.days.ago)
    @without_domain = insert_record(domain_id: Domain.maximum(:id) + 1, name: 'deleted.test',
                                    updated_at: 1.day.ago)
  end

  teardown do
    ENV.delete('DRY_RUN')
  end

  def test_only_lists_leftovers_by_default
    assert_no_difference -> { WhoisRecord.count } do
      output = run_task

      assert_match(/would delete ##{@without_domain.id} deleted\.test .* - domain no longer exists/,
                   output)
      assert_match(/would delete ##{@stale.id} shop\.test .* - duplicate of ##{@current.id} /,
                   output)
      assert_match(/2 of #{WhoisRecord.count} Registry whois records are leftovers/, output)
      assert_match(/1  without a domain/, output)
      assert_match(/1  duplicates, 1 domains have more than one record/, output)
    end
  end

  def test_deletes_leftovers_when_dry_run_is_disabled
    ENV['DRY_RUN'] = 'false'
    run_task

    assert_not WhoisRecord.exists?(@without_domain.id)
    assert_not WhoisRecord.exists?(@stale.id)
    assert WhoisRecord.exists?(@current.id)
  end

  def test_keeps_whois_server_record_of_live_domain
    ENV['DRY_RUN'] = 'false'
    run_task

    assert Whois::Record.exists?(@whois_server_record.id)
  end

  private

  # Bypasses callbacks, as leftovers cannot be created through the model
  def insert_record(attributes)
    result = WhoisRecord.insert!(attributes.merge(json: { name: attributes[:name] },
                                                  created_at: attributes[:updated_at]))
    WhoisRecord.find(result.rows.first.first)
  end

  def run_task
    capture_io { Rake::Task['whois:remove_registry_duplicates'].execute }.first
  end
end
