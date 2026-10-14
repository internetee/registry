require 'test_helper'

class VersionReservedDomainVersionTest < ActiveSupport::TestCase
  AUDIT_META = { source: nil, reason: nil, reason_note: nil,
                 domain_name: nil, registrar_id: nil }.freeze

  test 'backfill maps AdminUser whodunnit to admin source' do
    version = legacy_version('bf-admin.test', whodunnit: '12-AdminUser: administrator')

    assert version.backfill_audit!
    assert_equal 'admin', version.reload.source
    assert_nil version.reason
  end

  test 'backfill maps ApiUser whodunnit to registrar source' do
    version = legacy_version('bf-api.test', whodunnit: '45-ApiUser: api_user')

    assert version.backfill_audit!
    assert_equal 'registrar', version.reload.source
    assert_nil version.reason
  end

  test 'backfill maps daily cleanup whodunnit to expiry_job and reservation_expired' do
    whodunnit = "#{ReservedDomain::DAILY_CLEANUP_PROCESS} - " \
                "#{ReservedDomain::EXPIRED_RELEASE_REASON} - #{1.day.ago.iso8601}"
    version = legacy_version('bf-cron.test', whodunnit: whodunnit)

    assert version.backfill_audit!
    assert_equal 'expiry_job', version.reload.source
    assert_equal 'reservation_expired', version.reason
  end

  test 'backfill maps availability check whodunnit to availability_check and reservation_expired' do
    whodunnit = "#{ReservedDomain::AVAILABILITY_CHECK_PROCESS} - " \
                "#{ReservedDomain::EXPIRED_RELEASE_REASON} - #{1.day.ago.iso8601}"
    version = legacy_version('bf-lazy.test', whodunnit: whodunnit)

    assert version.backfill_audit!
    assert_equal 'availability_check', version.reload.source
    assert_equal 'reservation_expired', version.reason
  end

  test 'backfill maps console and rake whodunnits' do
    console_version = legacy_version('bf-console.test', whodunnit: 'console-oleghasjanov')
    rake_version = legacy_version('bf-rake.test', whodunnit: 'rake-reserved_domains:cleanup')

    assert console_version.backfill_audit!
    assert rake_version.backfill_audit!
    assert_equal 'console', console_version.reload.source
    assert_equal 'rake', rake_version.reload.source
  end

  test 'backfill upgrades a provable mapping on an unknown source' do
    version = legacy_version('bf-unknown-upgrade.test', whodunnit: '45-ApiUser: api_user')
    version.update_columns(source: 'unknown')

    assert version.backfill_audit!
    assert_equal 'registrar', version.reload.source
  end

  test 'backfill sets unknown on NULL source when whodunnit is unmapped' do
    version = legacy_version('bf-repp.test', whodunnit: 'repp_username')

    assert version.backfill_audit!
    assert_equal 'unknown', version.reload.source
    assert_nil version.reason
  end

  test 'backfill leaves an existing unknown source untouched when whodunnit is unmapped' do
    version = create_version('bf-stays-unknown.test', whodunnit: 'repp_username')

    assert_equal 'unknown', version.source # stage-1 fallback already wrote 'unknown'
    assert version.domain_name.present?

    assert_not version.backfill_audit!
    assert_equal 'unknown', version.reload.source
  end

  test 'backfill fills domain_name and leaves a real source alone' do
    version = create_version('bf-keep-source.test', whodunnit: '12-AdminUser: administrator')
    version.update_columns(domain_name: nil)

    assert version.backfill_audit!
    assert_equal 'bf-keep-source.test', version.reload.domain_name
    assert_equal 'admin', version.source
    assert_nil version.reason
  end

  test 'backfill keeps an existing reason' do
    whodunnit = "#{ReservedDomain::DAILY_CLEANUP_PROCESS} - " \
                "#{ReservedDomain::EXPIRED_RELEASE_REASON} - #{1.day.ago.iso8601}"
    version = legacy_version('bf-keep-reason.test', whodunnit: whodunnit)
    version.update_columns(reason: 'admin_deleted')

    assert version.backfill_audit!
    assert_equal 'expiry_job', version.reload.source
    assert_equal 'admin_deleted', version.reason
  end

  test 'backfill resolves destroy name from the object snapshot' do
    record = create_reservation('bf-destroy.test', whodunnit: 'console-tester')
    record.destroy!
    version = Version::ReservedDomainVersion.where(item_id: record.id, event: 'destroy').last
    version.update_columns(AUDIT_META)

    assert version.backfill_audit!
    assert_equal 'bf-destroy.test', version.reload.domain_name
  end

  test 'backfill never touches whodunnit object object_changes or created_at' do
    version = legacy_version('bf-immutable.test', whodunnit: '12-AdminUser: administrator')
    before = version.attributes.slice('whodunnit', 'object', 'object_changes', 'created_at')

    version.backfill_audit!

    assert_equal before, version.reload.attributes.slice(*before.keys)
  end

  test 'backfill is idempotent' do
    version = legacy_version('bf-idempotent.test', whodunnit: '12-AdminUser: administrator')

    assert version.backfill_audit!
    assert_not version.backfill_audit!
    assert_equal 'admin', version.reload.source
    assert_equal 'bf-idempotent.test', version.domain_name
  end

  private

  def create_reservation(name, whodunnit: nil)
    record = nil
    PaperTrail.request(whodunnit: whodunnit) do
      record = ReservedDomain.create!(name: name)
    end
    record
  end

  def create_version(name, whodunnit: nil)
    record = create_reservation(name, whodunnit: whodunnit)
    Version::ReservedDomainVersion.where(item_id: record.id).order(:id).last
  end

  def legacy_version(name, whodunnit: nil)
    version = create_version(name, whodunnit: whodunnit)
    version.update_columns(AUDIT_META)
    version.reload
  end
end
