require 'test_helper'

class ReservedDomainAuditTest < ActiveSupport::TestCase
  setup do
    @reserved_domain = reserved_domains(:one)
  end

  test 'create inside Audit.set writes audit metadata to version' do
    registrar = registrars(:bestnames)

    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_created',
                              reason_note: 'manual reservation', registrar_id: registrar.id) do
      ReservedDomain.create!(name: 'audit-create.test')
    end

    version = Version::ReservedDomainVersion.last
    assert_equal 'create', version.event
    assert_equal 'admin', version.source
    assert_equal 'admin_created', version.reason
    assert_equal 'manual reservation', version.reason_note
    assert_equal 'audit-create.test', version.domain_name
    assert_equal registrar.id, version.registrar_id
  end

  test 'update inside Audit.set writes audit metadata' do
    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated', reason_note: 'fix expiry') do
      @reserved_domain.update!(expire_at: 1.year.from_now)
    end

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'update', version.event
    assert_equal 'admin', version.source
    assert_equal 'admin_updated', version.reason
    assert_equal 'fix expiry', version.reason_note
    assert_equal @reserved_domain.name, version.domain_name
  end

  test 'rename writes the new name to domain_name' do
    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated') do
      @reserved_domain.update!(name: 'renamed.test')
    end

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'renamed.test', version.domain_name
  end

  test 'destroy inside Audit.set writes audit metadata' do
    registrar = registrars(:bestnames)

    ReservedDomain::Audit.set(source: 'registrar', reason: 'domain_registered',
                              registrar_id: registrar.id) do
      @reserved_domain.destroy!
    end

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'destroy', version.event
    assert_equal 'registrar', version.source
    assert_equal 'domain_registered', version.reason
    assert_equal 'reserved.test', version.domain_name
    assert_equal registrar.id, version.registrar_id
  end

  test 'source falls back to whodunnit when Audit is not set' do
    {
      '123-AdminUser: administrator' => 'admin',
      '45-ApiUser: api_user' => 'registrar',
      'console-oleghasjanov' => 'console',
      'rake-reserved_domains:cleanup' => 'rake',
      'Automated daily cleanup job - Expired' => 'unknown',
      'totally other' => 'unknown'
    }.each_with_index do |(whodunnit, expected), index|
      record = nil
      PaperTrail.request(whodunnit: whodunnit) do
        record = ReservedDomain.create!(name: "fallback-#{index}.test")
      end

      version = Version::ReservedDomainVersion.where(item_id: record.id).last
      assert_equal expected, version.source, "unexpected source for whodunnit #{whodunnit.inspect}"
      assert_nil version.reason
      assert_nil version.reason_note
      assert_nil version.registrar_id
      assert_equal "fallback-#{index}.test", version.domain_name
    end
  end

  test 'no whodunnit at all falls back to unknown source' do
    record = ReservedDomain.create!(name: 'no-context.test')

    version = Version::ReservedDomainVersion.where(item_id: record.id).last
    assert_equal 'unknown', version.source
    assert_nil version.reason
  end

  test 'nested Audit.set overrides and restores outer values' do
    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated') do
      assert_equal 'admin', ReservedDomain::Audit.source
      assert_equal 'admin_updated', ReservedDomain::Audit.reason

      ReservedDomain::Audit.set(source: 'dispute', reason: 'dispute_password_sync') do
        assert_equal 'dispute', ReservedDomain::Audit.source
        assert_equal 'dispute_password_sync', ReservedDomain::Audit.reason

        record = ReservedDomain.create!(name: 'nested.test')
        version = Version::ReservedDomainVersion.where(item_id: record.id).last
        assert_equal 'dispute', version.source
        assert_equal 'dispute_password_sync', version.reason
      end

      assert_equal 'admin', ReservedDomain::Audit.source
      assert_equal 'admin_updated', ReservedDomain::Audit.reason
    end

    assert_nil ReservedDomain::Audit.source
    assert_nil ReservedDomain::Audit.reason
  end

  test 'exception in nested Audit.set with PaperTrail.request restores outer values' do
    outer_registrar = registrars(:bestnames)
    inner_registrar = registrars(:goodnames)

    ReservedDomain::Audit.set(source: 'admin', reason: 'admin_created',
                              reason_note: 'outer note', registrar_id: outer_registrar.id) do
      PaperTrail.request(whodunnit: 'outer-whodunnit') do
        assert_raises(RuntimeError) do
          ReservedDomain::Audit.set(source: 'registrar', reason: 'domain_registered',
                                    reason_note: 'inner note', registrar_id: inner_registrar.id) do
            PaperTrail.request(whodunnit: 'inner-whodunnit') do
              assert_equal 'registrar', ReservedDomain::Audit.source
              assert_equal 'inner-whodunnit', PaperTrail.request.whodunnit
              raise 'boom'
            end
          end
        end

        assert_equal 'admin', ReservedDomain::Audit.source
        assert_equal 'admin_created', ReservedDomain::Audit.reason
        assert_equal 'outer note', ReservedDomain::Audit.reason_note
        assert_equal outer_registrar.id, ReservedDomain::Audit.registrar_id
        assert_equal 'outer-whodunnit', PaperTrail.request.whodunnit
      end
    end

    assert_nil ReservedDomain::Audit.source
    assert_nil ReservedDomain::Audit.reason
    assert_nil ReservedDomain::Audit.reason_note
    assert_nil ReservedDomain::Audit.registrar_id
  end

  test 'domain versions still record children meta' do
    domain = domains(:shop)
    domain.update!(outzone_at: 1.year.from_now)

    version = Version::DomainVersion.where(item_id: domain.id).last
    assert_equal domain.admin_contact_ids, version.children['admin_contacts']
    assert_equal domain.nameserver_ids, version.children['nameservers']
  end
end
