require 'test_helper'

class Version::DomainVersion::ResolverTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
    @admin = users(:admin)
  end

  def test_resolves_live_domain_without_reconstruction
    domain = domains(:shop)
    version = Version::DomainVersion.where(item_id: domain.id).first
    skip 'no fixtures versions' unless version

    resolver = Version::DomainVersion::Resolver.new(version)

    assert_equal domain.id, resolver.domain.id
    refute resolver.deleted?
    assert_equal domain.name, resolver.domain_name
  end

  def test_reconstructs_domain_from_create_version_with_nil_object
    item_id = next_unused_item_id
    version = build_version(
      item_id: item_id,
      event: 'create',
      object: nil,
      object_changes: {
        'name' => [nil, 'ghost.test'],
        'registrar_id' => [nil, @registrar.id],
      }
    )

    resolver = Version::DomainVersion::Resolver.new(version)

    assert resolver.deleted?
    assert_equal 'ghost.test', resolver.domain_name
    assert_equal @registrar.id, resolver.registrar_id
    assert_equal @registrar, resolver.registrar
    assert_not_nil resolver.domain.created_at
    assert_not_nil resolver.domain.updated_at
  end

  def test_reconstructs_domain_from_update_version_via_reify
    item_id = next_unused_item_id
    build_version(
      item_id: item_id,
      event: 'create',
      object: nil,
      object_changes: { 'name' => [nil, 'gone.test'], 'registrar_id' => [nil, @registrar.id] }
    )
    update_version = build_version(
      item_id: item_id,
      event: 'update',
      object: { 'name' => 'gone.test', 'registrar_id' => @registrar.id },
      object_changes: { 'statuses' => [[], ['serverHold']] }
    )

    resolver = Version::DomainVersion::Resolver.new(update_version)

    assert resolver.deleted?
    assert_equal 'gone.test', resolver.domain_name
    assert_equal @registrar.id, resolver.registrar_id
  end

  def test_domain_name_falls_back_through_object_and_changes
    item_id = next_unused_item_id
    version = build_version(
      item_id: item_id,
      event: 'destroy',
      object: { 'name' => 'from-object.test' },
      object_changes: nil
    )

    resolver = Version::DomainVersion::Resolver.new(version)

    assert_equal 'from-object.test', resolver.domain_name
  end

  def test_domain_name_returns_nil_when_no_data_available
    item_id = next_unused_item_id
    version = build_version(
      item_id: item_id,
      event: 'update',
      object: nil,
      object_changes: nil
    )

    resolver = Version::DomainVersion::Resolver.new(version)

    assert_nil resolver.domain_name
  end

  def test_registrar_memoizes_missing_lookup
    item_id = next_unused_item_id
    missing_registrar_id = Registrar.maximum(:id).to_i + 9999
    version = build_version(
      item_id: item_id,
      event: 'create',
      object: nil,
      object_changes: { 'name' => [nil, 'x.test'], 'registrar_id' => [nil, missing_registrar_id] }
    )
    resolver = Version::DomainVersion::Resolver.new(version)
    resolver.registrar # prime memoization

    assert_queries(0) { 3.times { resolver.registrar } }
    assert_nil resolver.registrar
  end

  private

  def build_version(attrs)
    Version::DomainVersion.create!(
      item_type: 'Domain',
      whodunnit: @admin.id.to_s,
      created_at: Time.zone.now,
      **attrs
    )
  end

  def next_unused_item_id
    @next_unused_item_id ||= Domain.maximum(:id).to_i +
                             Version::DomainVersion.maximum(:item_id).to_i +
                             5000
    @next_unused_item_id += 1
  end

  def assert_queries(expected)
    count = 0
    counter = ->(_name, _start, _finish, _id, payload) do
      count += 1 unless payload[:name] == 'SCHEMA' || payload[:sql].include?('TRANSACTION')
    end
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { yield }
    assert_equal expected, count, "expected #{expected} queries, got #{count}"
  end
end
