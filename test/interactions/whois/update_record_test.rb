require 'test_helper'

class WhoisUpdateRecordTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:airport)
  end

  def test_registry_whois_record_is_unique_per_domain_on_database_level
    insert_record

    assert_raises ActiveRecord::RecordNotUnique do
      WhoisRecord.transaction(requires_new: true) { insert_record }
    end
  end

  def test_updates_existing_record_when_concurrent_job_creates_it_first
    assert_nil @domain.whois_record
    insert_record

    Domain.stub(:find_by, @domain) do
      Whois::UpdateRecord.run(record: { klass: 'Domain', id: @domain.id, type: 'domain' })
    end

    record = WhoisRecord.find_by!(domain_id: @domain.id)
    assert_equal 1, WhoisRecord.where(domain_id: @domain.id).count
    assert_equal @domain.name, record.json['name']
  end

  private

  def insert_record
    WhoisRecord.insert!({ domain_id: @domain.id, name: @domain.name, json: {},
                          created_at: Time.zone.now, updated_at: Time.zone.now })
  end
end
