require 'test_helper'

class ReservedDomainLifecycleTest < ActiveSupport::TestCase
  AUDIT_META = { source: nil, reason: nil, reason_note: nil,
                 domain_name: nil, registrar_id: nil }.freeze

  test 'live reservation shows as active' do
    record = create_reservation('active-lc.test', expire_at: 1.year.from_now)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'active', lifecycle.status
    assert_equal 'active-lc.test', lifecycle.domain_name
    assert_equal record.expire_at.to_i, lifecycle.expire_at.to_i
    assert_equal 'console-tester', lifecycle.created_by
    assert_equal 'console-tester', lifecycle.last_changed_by
    assert_equal 'console', lifecycle.creation_source
    assert_equal record.created_at.to_i, lifecycle.created_at.to_i
    assert_nil lifecycle.ended_at
    assert_nil lifecycle.end_reason
  end

  test 'live reservation past expiry shows as expired' do
    record = create_reservation('live-expired.test', expire_at: 1.day.ago)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'expired', lifecycle.status
    assert_nil lifecycle.ended_at
    assert_nil lifecycle.end_reason
  end

  test 'permanent reservation keeps NULL expire_at and stays active' do
    record = create_reservation('permanent-lc.test', expire_at: nil)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'active', lifecycle.status
    assert_nil lifecycle.expire_at
  end

  test 'reservation destroyed by daily cleanup shows as expired' do
    record = create_reservation('cron-expired.test', expire_at: 1.day.ago)
    assert record.release_if_expired(process: ReservedDomain::DAILY_CLEANUP_PROCESS)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'expired', lifecycle.status
    assert_equal 'reservation_expired', lifecycle.end_reason
    assert_equal 'expiry_job', lifecycle.last_source

    destroy_version = Version::ReservedDomainVersion.where(item_id: record.id, event: 'destroy').last
    assert_equal destroy_version.created_at.to_i, lifecycle.ended_at.to_i
  end

  test 'reservation destroyed by availability check shows as expired' do
    record = create_reservation('lazy-expired.test', expire_at: 1.day.ago)
    assert record.destroy_if_expired

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'expired', lifecycle.status
    assert_equal 'availability_check', lifecycle.last_source
  end

  test 'reservation destroyed with released_to_auction reason shows as released_to_auction' do
    record = create_reservation('auctioned.test')
    destroy_with_audit(record, reason: 'released_to_auction')

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'released_to_auction', lifecycle.status
    assert_equal 'released_to_auction', lifecycle.end_reason
    assert lifecycle.ended_at.present?
  end

  test 'reservation destroyed with admin_deleted reason shows as deleted' do
    record = create_reservation('deleted.test')
    destroy_with_audit(record, reason: 'admin_deleted', reason_note: 'court order')

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'deleted', lifecycle.status
    assert_equal 'admin_deleted', lifecycle.end_reason
    assert_equal 'court order', lifecycle.last_reason_note
  end

  test 'reservation destroyed without reason shows as removed' do
    record = create_reservation('removed.test')
    record.destroy!

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'removed', lifecycle.status
    assert_nil lifecycle.end_reason
    assert lifecycle.ended_at.present?
  end

  test 'end_reason and ended_at come from the destroy event not the preceding update' do
    record = create_reservation('end-reason.test')

    PaperTrail.request(whodunnit: '1-AdminUser: administrator') do
      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated') do
        record.update!(expire_at: 2.years.from_now)
      end
      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_deleted') do
        record.destroy!
      end
    end

    update_version = Version::ReservedDomainVersion.where(item_id: record.id, event: 'update').last
    destroy_version = Version::ReservedDomainVersion.where(item_id: record.id, event: 'destroy').last

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'admin_deleted', lifecycle.end_reason
    assert_equal 'deleted', lifecycle.status
    assert_equal destroy_version.created_at.to_i, lifecycle.ended_at.to_i
    assert lifecycle.ended_at >= update_version.created_at
  end

  test 'legacy create version without meta resolves name from object_changes' do
    record = create_reservation('legacy-create.test')
    nullify_meta_for(record)
    record.delete # removes the live row without a destroy version

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'legacy-create.test', lifecycle.domain_name
  end

  test 'legacy destroy version without meta resolves name from object snapshot' do
    record = create_reservation('legacy-destroy.test')
    record.destroy!
    nullify_meta_for(record)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'legacy-destroy.test', lifecycle.domain_name
    assert_equal 'removed', lifecycle.status
  end

  test 'legacy renamed reservation shows the new name' do
    record = create_reservation('legacy-old.test')
    record.update!(name: 'legacy-new.test')
    nullify_meta_for(record)
    record.delete

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'legacy-new.test', lifecycle.domain_name
  end

  test 'created_by falls back to create event whodunnit when the live row is gone' do
    record = nil
    PaperTrail.request(whodunnit: 'console-creator') do
      record = ReservedDomain.create!(name: 'created-by-whodunnit.test')
      record.destroy!
    end

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'console-creator', lifecycle.created_by
    assert_equal 'console-creator', lifecycle.last_changed_by
  end

  test 'created_by falls back to snapshot creator_str when no create event exists' do
    record = nil
    PaperTrail.request(whodunnit: 'console-creator') do
      record = ReservedDomain.create!(name: 'created-by-snapshot.test')
      record.destroy!
    end

    Version::ReservedDomainVersion.where(item_id: record.id, event: 'create').delete_all
    assert_equal 1, Version::ReservedDomainVersion.where(item_id: record.id).count

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'console-creator', lifecycle.created_by
  end

  test 'live reservation without versions still appears' do
    record = nil
    PaperTrail.request(whodunnit: 'console-import', enabled: false) do
      record = ReservedDomain.create!(name: 'unversioned.test')
    end

    assert_equal 0, Version::ReservedDomainVersion.where(item_id: record.id).count

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'unversioned.test', lifecycle.domain_name
    assert_equal 'console-import', lifecycle.created_by
    assert_equal 'console-import', lifecycle.last_changed_by
    assert_equal 'active', lifecycle.status
    assert_nil lifecycle.creation_source
    assert_nil lifecycle.creation_reason
  end

  test 'registration_recorded is set after a domain_registered event' do
    record = create_reservation('registered.test')

    ReservedDomain::Audit.set(source: 'registrar', reason: 'domain_registered',
                              registrar_id: registrars(:bestnames).id) do
      ReservedDomain.new_password_for('registered.test')
    end

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert lifecycle.registration_recorded
    assert_equal 'domain_registered', lifecycle.last_reason
    assert_equal 'registrar', lifecycle.last_source
  end

  test 'registration_recorded is false without a domain_registered event' do
    record = create_reservation('never-registered.test')

    assert_not ReservedDomain::Lifecycle.find(record.id).registration_recorded
  end

  test 'versions returns the full ordered version history' do
    record = create_reservation('versioned.test')
    record.update!(expire_at: 2.years.from_now)

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal %w[create update], lifecycle.versions.map(&:event)
  end

  test 'row deleted without destroy version keeps updated expire_at and shows removed' do
    record = nil
    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_created') do
      record = ReservedDomain.create!(name: 'silently-deleted.test', expire_at: 1.year.from_now)
    end

    new_expire_at = Time.zone.parse('2031-06-01 12:00:00')
    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated') do
      record.update!(expire_at: new_expire_at)
    end

    ReservedDomain.where(id: record.id).delete_all
    assert_equal 0, Version::ReservedDomainVersion.where(item_id: record.id, event: 'destroy').count

    lifecycle = ReservedDomain::Lifecycle.find(record.id)
    assert_equal 'removed', lifecycle.status
    assert_nil lifecycle.ended_at
    assert_equal new_expire_at.to_i, lifecycle.expire_at.to_i
  end

  test 'lifecycle rows are read-only' do
    lifecycle = ReservedDomain::Lifecycle.find(reserved_domains(:one).id)

    assert lifecycle.readonly?
    assert_raises(ActiveRecord::ReadOnlyRecord) { lifecycle.destroy }
    assert_raises(ActiveRecord::ReadOnlyRecord) { lifecycle.update(domain_name: 'x.test') }
  end

  private

  def create_reservation(name, expire_at: 5.years.from_now)
    record = nil
    PaperTrail.request(whodunnit: 'console-tester') do
      record = ReservedDomain.create!(name: name, expire_at: expire_at)
    end
    record
  end

  def destroy_with_audit(record, reason:, reason_note: nil)
    PaperTrail.request(whodunnit: '1-AdminUser: administrator') do
      ReservedDomain::Audit.set(source: 'admin', reason: reason, reason_note: reason_note) do
        record.destroy!
      end
    end
  end

  def nullify_meta_for(record)
    Version::ReservedDomainVersion.where(item_id: record.id).find_each do |version|
      version.update_columns(AUDIT_META)
    end
  end
end
