require 'test_helper'

class ReservedDomainsTaskTest < ActiveSupport::TestCase
  AUDIT_META = { source: nil, reason: nil, reason_note: nil,
                 domain_name: nil, registrar_id: nil }.freeze

  test 'backfill_audit fills audit metadata on legacy versions' do
    admin_version = legacy_version('task-admin.test', whodunnit: '12-AdminUser: administrator')
    cron_version = legacy_version('task-cron.test',
                                  whodunnit: "#{ReservedDomain::DAILY_CLEANUP_PROCESS} - x")
    repp_version = legacy_version('task-repp.test', whodunnit: 'repp_username')

    run_task

    assert_equal 'admin', admin_version.reload.source
    assert_equal 'task-admin.test', admin_version.domain_name

    assert_equal 'expiry_job', cron_version.reload.source
    assert_equal 'reservation_expired', cron_version.reason

    assert_equal 'unknown', repp_version.reload.source
    assert_equal 'task-repp.test', repp_version.domain_name
  end

  test 'backfill_audit does not touch whodunnit or snapshots' do
    version = legacy_version('task-immutable.test', whodunnit: '12-AdminUser: administrator')
    before = version.attributes.slice('whodunnit', 'object', 'object_changes', 'created_at')

    run_task

    assert_equal before, version.reload.attributes.slice(*before.keys)
  end

  test 'backfill_audit is idempotent' do
    version = legacy_version('task-twice.test', whodunnit: '12-AdminUser: administrator')

    run_task
    after_first_run = version.reload.attributes
    run_task

    assert_equal after_first_run, version.reload.attributes
  end

  test 'backfill_audit rebuilds the history with backfilled metadata' do
    version = legacy_version('task-history.test', whodunnit: '12-AdminUser: administrator')
    ReservedDomain::Lifecycle.sync!
    assert_nil ReservedDomain::Lifecycle.find(version.item_id).creation_source

    run_task

    assert_equal 'admin', ReservedDomain::Lifecycle.find(version.item_id).creation_source
  end

  private

  def legacy_version(name, whodunnit: nil)
    record = nil
    PaperTrail.request(whodunnit: whodunnit) do
      record = ReservedDomain.create!(name: name)
    end
    version = Version::ReservedDomainVersion.where(item_id: record.id).order(:id).last
    version.update_columns(AUDIT_META)
    version.reload
  end

  def run_task
    Rake::Task['reserved_domains:backfill_audit'].execute
  end
end
