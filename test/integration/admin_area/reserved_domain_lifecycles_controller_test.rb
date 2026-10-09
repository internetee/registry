require 'test_helper'

class AdminAreaReservedDomainLifecyclesControllerTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)
  end

  def test_index_renders
    create_reservation('lifecycle-index.test')

    get admin_reserved_domain_lifecycles_path

    assert_response :ok
    assert_includes response.body, 'lifecycle-index.test'
  end

  def test_index_filters_by_domain_name_with_unicode_input
    create_reservation('õun-lifecycle.test')

    get admin_reserved_domain_lifecycles_path, params: { q: { domain_name_matches: 'õun-lifecycle' } }

    assert_response :ok
    assert_includes response.body, 'õun-lifecycle.test'
  end

  def test_index_filters_by_domain_name_with_punycode_input
    create_reservation('õun-lifecycle.test')

    get admin_reserved_domain_lifecycles_path,
        params: { q: { domain_name_matches: SimpleIDN.to_ascii('õun-lifecycle.test') } }

    assert_response :ok
    assert_includes response.body, 'õun-lifecycle.test'
  end

  def test_index_filters_by_status
    active = create_reservation('lifecycle-active.test', expire_at: 1.year.from_now)
    expired = create_reservation('lifecycle-expired.test', expire_at: 1.day.ago)

    get admin_reserved_domain_lifecycles_path, params: { q: { with_status: 'expired' } }

    assert_response :ok
    assert_includes response.body, expired.name
    assert_not_includes response.body, active.name
  end

  def test_index_filters_by_creation_source
    create_reservation('lifecycle-admin.test', source: 'admin', reason: 'admin_created')
    create_reservation('lifecycle-console.test', source: 'console')

    get admin_reserved_domain_lifecycles_path, params: { q: { creation_source_eq: 'admin' } }

    assert_response :ok
    assert_includes response.body, 'lifecycle-admin.test'
    assert_not_includes response.body, 'lifecycle-console.test'
  end

  def test_index_filters_by_last_reason
    create_reservation('lifecycle-paid.test', reason: 'paid_reservation')
    create_reservation('lifecycle-free.test', reason: 'free_reservation')

    get admin_reserved_domain_lifecycles_path, params: { q: { last_reason_eq: 'paid_reservation' } }

    assert_response :ok
    assert_includes response.body, 'lifecycle-paid.test'
    assert_not_includes response.body, 'lifecycle-free.test'
  end

  def test_index_created_at_lteq_filter_is_inclusive
    create_reservation('lifecycle-date.test')

    get admin_reserved_domain_lifecycles_path,
        params: { q: { created_at_lteq: Date.today.to_s } }

    assert_response :ok
    assert_includes response.body, 'lifecycle-date.test',
                    'Expected a reservation created today to match the created_at_lteq filter'

    get admin_reserved_domain_lifecycles_path,
        params: { q: { created_at_lteq: Date.yesterday.to_s } }

    assert_response :ok
    assert_not_includes response.body, 'lifecycle-date.test'
  end

  def test_index_filters_by_created_by
    create_reservation('lifecycle-creator.test', whodunnit: 'console-unique-creator')
    create_reservation('lifecycle-other.test', whodunnit: 'console-other-creator')

    get admin_reserved_domain_lifecycles_path, params: { q: { created_by_matches: 'unique-creator' } }

    assert_response :ok
    assert_includes response.body, 'lifecycle-creator.test'
    assert_not_includes response.body, 'lifecycle-other.test'
  end

  def test_show_renders_timeline_with_reason_note_and_masks_password
    record = create_reservation('lifecycle-show.test', password: 'topsecret-pw-value')

    PaperTrail.request(whodunnit: '1-AdminUser: administrator') do
      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated',
                                reason_note: 'Court order 123', registrar_id: nil) do
        record.update!(password: 'rotated-secret-pw')
      end
    end

    get admin_reserved_domain_lifecycle_path(record.id)

    assert_response :ok
    assert_includes response.body, 'Court order 123'
    assert_includes response.body, 'Admin updated'
    assert_includes response.body, 'password:'
    assert_not_includes response.body, 'topsecret-pw-value'
    assert_not_includes response.body, 'rotated-secret-pw'
  end

  def test_show_finds_reservation_created_after_previous_sync
    get admin_reserved_domain_lifecycles_path
    record = create_reservation('lifecycle-after-sync.test')

    get admin_reserved_domain_lifecycle_path(record.id)

    assert_response :ok
    assert_includes response.body, 'lifecycle-after-sync.test'
  end

  def test_index_renders_with_warning_when_sync_fails
    create_reservation('lifecycle-stale.test')
    ReservedDomain::Lifecycle.sync!

    ReservedDomain::Lifecycle.stub(:sync!, -> { raise ActiveRecord::StatementInvalid, 'boom' }) do
      get admin_reserved_domain_lifecycles_path
    end

    assert_response :ok
    assert_includes response.body, 'lifecycle-stale.test'
    assert_includes response.body, I18n.t('admin.reserved_domain_lifecycles.sync_failed')
  end

  def test_csv_export
    record = create_reservation('lifecycle-csv.test', password: 'csv-secret-pw',
                                                    source: 'admin', reason: 'admin_created',
                                                    reason_note: 'Manual csv note')
    registered = create_reservation(domains(:shop).name)

    get admin_reserved_domain_lifecycles_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_includes response.headers['Content-Disposition'],
                    'attachment; filename="reserved_domains_history_'
    assert_nil response.headers['ETag'], 'a buffered body would get an ETag'

    rows = CSV.parse(response.body)
    assert_equal ReservedDomain::Lifecycle::CSV_COLUMNS.map(&:to_s), rows.first

    row = rows.find { |r| r[1] == record.name }
    assert_not_nil row
    header = rows.first
    assert_equal 'active', row[header.index('status')]
    assert_equal 'admin', row[header.index('creation_source')]
    assert_equal 'admin_created', row[header.index('creation_reason')]
    assert_equal 'Manual csv note', row[header.index('last_reason_note')]
    assert_equal 'false', row[header.index('domain_exists')]
    assert_equal 'true', rows.find { |r| r[1] == registered.name }[header.index('domain_exists')]
    refute_includes response.body, 'csv-secret-pw'
  end

  def test_csv_export_empty_result_still_has_header
    get admin_reserved_domain_lifecycles_path(format: :csv),
        params: { q: { domain_name_matches: 'zzz-nothing-matches-this' } }

    assert_response :ok

    rows = CSV.parse(response.body)
    assert_equal 1, rows.size
    assert_equal ReservedDomain::Lifecycle::CSV_COLUMNS.map(&:to_s), rows.first
  end

  def test_non_admin_user_cannot_access
    sign_out users(:admin)
    sign_in users(:api_bestnames)

    get admin_reserved_domain_lifecycles_path

    assert_redirected_to new_admin_user_session_path
  end

  private

  def create_reservation(name, whodunnit: 'console-tester', source: nil, reason: nil,
                         reason_note: nil, **attrs)
    record = nil
    PaperTrail.request(whodunnit: whodunnit) do
      ReservedDomain::Audit.set(source: source, reason: reason,
                                reason_note: reason_note, registrar_id: nil) do
        record = ReservedDomain.create!(name: name, **attrs)
      end
    end
    record
  end
end
