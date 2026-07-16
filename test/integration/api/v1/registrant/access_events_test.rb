require 'test_helper'
require 'auth_token/auth_token_creator'

# spec 13, Surface A: GET /api/v1/registrant/domains/:uuid/access_events
#
# Fixture ground truth (see test/fixtures/{domains,contacts,log_domains,rdap_access_events}.yml):
#   users(:registrant) == US-1234 resolves via Contact.registrant_user_direct_contacts to
#   contacts(:john) only (ident 1234, US). contacts(:jane) is the other/prior/intervening owner.
#   domains(:mytenure) (name mytenure.test) is currently john's; its log_domains timeline gives
#   john the tenure intervals [2021-01-01, 2022-01-01) and [2023-01-01, now); jane owns
#   [2020-01-01, 2021-01-01) and [2022-01-01, 2023-01-01).
class RegistrantApiV1AccessEventsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:registrant)
    @domain = domains(:mytenure)
  end

  def test_route_exists_per_domain_only
    get access_events_path(@domain.uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
    assert_kind_of Array, JSON.parse(response.body)
  end

  def test_missing_and_invalid_token_return_401
    get access_events_path(@domain.uuid), as: :json
    assert_response :unauthorized

    get access_events_path(@domain.uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => 'Bearer garbage-not-a-token' }
    assert_response :unauthorized
  end

  def test_ignores_client_supplied_registrant_and_contact_and_ident
    clean_body = get_events(@domain.uuid)

    # Inject a foreign registrant id / contact id (jane, id 123456) and an ident header —
    # all must be ignored; scoping is derived only from current_registrant_user.
    get access_events_path(@domain.uuid) + '?registrant_id=999999&contact_id=999999',
        as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token,
                   'X-Registrant-Ident' => '123456' }
    assert_response :ok
    injected_body = JSON.parse(response.body)

    assert_equal clean_body, injected_body
  end

  def test_event_during_caller_tenure_is_returned
    body = get_events(@domain.uuid)
    # mytenure_in_first_tenure (2021-06-01) is inside [2021-01-01, 2022-01-01).
    assert_includes accessed_ats(body), iso('2021-06-01 10:00:00')
  end

  def test_prior_owner_event_excluded
    body = get_events(@domain.uuid)
    # mytenure_prior_owner (2020-06-01) is before john's earliest tenure start.
    refute_includes accessed_ats(body), iso('2020-06-01 10:00:00')
  end

  def test_later_owner_and_transfer_instant_events_excluded
    body = get_events(@domain.uuid)
    # transfer instant == end (2022-01-01 00:00:00) belongs to the acquiring owner.
    refute_includes accessed_ats(body), iso('2022-01-01 00:00:00')
    # intervening owner's interval [2022-01-01, 2023-01-01).
    refute_includes accessed_ats(body), iso('2022-06-01 10:00:00')
  end

  def test_two_noncontiguous_tenures_return_both_own_intervals_only
    body = get_events(@domain.uuid)
    ats = accessed_ats(body)
    assert_includes ats, iso('2021-06-01 10:00:00') # first own interval
    assert_includes ats, iso('2023-06-01 10:00:00') # second own interval
    refute_includes ats, iso('2022-06-01 10:00:00') # intervening owner
  end

  def test_namesake_different_item_id_event_excluded
    body = get_events(@domain.uuid)
    # 2015-06-01 mytenure.test event lies outside every interval of this item_id.
    refute_includes accessed_ats(body), iso('2015-06-01 10:00:00')
  end

  def test_unknown_and_other_registrant_uuid_return_identical_404
    unknown_uuid = '00000000-0000-0000-0000-000000000000'
    other_uuid = domains(:metro).uuid # owned by jack, not the caller

    get access_events_path(unknown_uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }
    assert_response :not_found
    unknown_body = response.body

    get access_events_path(other_uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }
    assert_response :not_found
    other_body = response.body

    assert_equal({ 'errors' => [{ 'base' => ['Domain not found'] }] }, JSON.parse(unknown_body))
    assert_equal unknown_body, other_body # byte-identical, no existence leak
  end

  def test_delay_filter_in_window_absent_past_cutoff_present
    with_setting('rdap_access_transparency_disclosure_delay', '5') do
      body = get_events(@domain.uuid)
      ats = accessed_ats(body)
      # 2-hours-ago event is past the 5-minute cutoff -> present.
      assert(ats.any? { |a| Time.zone.parse(a) < 30.minutes.ago },
             'expected a past-cutoff event in the response')
      # 1-minute-ago event is inside the suppression window -> absent.
      refute(ats.any? { |a| Time.zone.parse(a) > 30.minutes.ago },
             'in-window (newer than cutoff) event must be absent')
    end
  end

  def test_setting_value_and_missing_setting_5min_fallback
    # (a) a controlled Setting value drives the cutoff.
    with_setting('rdap_access_transparency_disclosure_delay', '5') do
      body = get_events(@domain.uuid)
      refute(accessed_ats(body).any? { |a| Time.zone.parse(a) > 30.minutes.ago })
    end

    # (b) with the Setting row ABSENT, the 5-minute non-zero fallback still suppresses the
    # in-window event (never real-time / 0-delay).
    SettingEntry.where(code: 'rdap_access_transparency_disclosure_delay').destroy_all
    assert_nil Setting.rdap_access_transparency_disclosure_delay
    body = get_events(@domain.uuid)
    refute(accessed_ats(body).any? { |a| Time.zone.parse(a) > 30.minutes.ago },
           'missing Setting must fall back to 5 minutes, not 0-delay')
  end

  def test_order_desc_and_cap_100_after_filtering
    cap_uuid = domains(:capdomain).uuid
    body = get_events(cap_uuid)

    assert_equal 100, body.size
    ats = body.map { |e| Time.zone.parse(e['accessed_at']) }
    assert_equal ats.sort.reverse, ats, 'events must be ordered requested_at DESC'
    # The 100 returned are the most-recent disclosable ones (cap applied post-filter): the
    # oldest capdomain event (capdomain_event_101 at 102h ago) must be excluded.
    refute_includes body.map { |e| e['accessed_at'] }, iso_time(102.hours.ago)
  end

  def test_response_has_exactly_three_keys_and_no_withheld_fields
    body = get_events(@domain.uuid)
    assert body.any?, 'expected at least one disclosable event'

    body.each do |event|
      assert_equal %w[accessed_at category organization], event.keys.sort
      # accessed_at parses as ISO-8601 with a timezone offset.
      assert_match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}\z/, event['accessed_at'])
    end

    # null organization_name -> organization: null (mytenure_in_second_tenure_null_org).
    null_org = body.find { |e| e['accessed_at'] == iso('2023-06-01 10:00:00') }
    assert null_org, 'expected the null-organization event to be disclosed'
    assert_nil null_org['organization']

    raw = response.body
    %w[accessor_name grant_ref request_id caller_ip result_code created_at
       eeid_subject personal_id_code Officer\ Alpha Namesake].each do |withheld|
      refute_includes raw, withheld, "response body must not contain #{withheld}"
    end
    # the caller's own ident must not leak.
    refute_includes raw, @user.ident
  end

  def test_no_pii_in_logs_across_happy_404_401
    logged = capture_rails_log do
      get_events(@domain.uuid)
      get access_events_path('00000000-0000-0000-0000-000000000000'), as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
      get access_events_path(@domain.uuid), as: :json # 401
    end

    refute_includes logged, @user.ident # caller's ident string
    refute_includes logged, 'Officer Alpha' # accessor personal identifier
    refute_includes logged, 'Namesake Access'
    refute_includes logged, 'Recent Officer'
  end

  def test_read_only_no_store_or_related_writes
    assert_no_difference ['RdapAccessEvent.count', 'Version::DomainVersion.count',
                          'Domain.count', 'Contact.count'] do
      get_events(@domain.uuid)
      get access_events_path('00000000-0000-0000-0000-000000000000'), as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
      get access_events_path(@domain.uuid), as: :json # 401
    end
  end

  # FAIL-CLOSED regression (M1): the caller CURRENTLY owns domains(:orphan) but the log_domains
  # timeline never records john becoming registrant — only the prior owner (jane) appears. The old
  # fail-OPEN live tail anchored to rows.first (2020) and emitted [2020, now), leaking jane's
  # prior-tenure police lookup. The fix emits NO interval, so nothing is disclosed.
  def test_fail_closed_caller_never_in_timeline_excludes_prior_owner_event
    orphan_uuid = domains(:orphan).uuid
    body = get_events(orphan_uuid)

    assert_equal [], body,
                 'caller absent from the recorded timeline must disclose NO events (fail closed)'
    refute_includes accessed_ats(body), iso('2020-06-01 10:00:00')
  end

  # FAIL-CLOSED sub-case (M1): the caller CURRENTLY owns domains(:partial) and DID appear as
  # effective registrant earlier (2021), but the last recorded change hands it back to jane (2022)
  # with no john re-acquire row. The fix anchors the live tail to john's last effective-registrant
  # version (2021): only events at/after 2021 are disclosed, jane's pre-2021 event stays excluded.
  def test_fail_closed_caller_earlier_in_timeline_anchors_to_last_own_version
    partial_uuid = domains(:partial).uuid
    body = get_events(partial_uuid)
    ats = accessed_ats(body)

    assert_includes ats, iso('2021-06-01 10:00:00'),
                    'event after the caller last-own version (2021) must be disclosed'
    refute_includes ats, iso('2020-06-01 10:00:00'),
                    'prior-owner event before the caller last-own version must be excluded'
  end

  def test_owned_domain_zero_events_returns_200_empty_array
    # domains(:hospital) is john's but has no rdap_access_events rows (hospital.test).
    empty_domain = domains(:hospital)
    get access_events_path(empty_domain.uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
    assert_equal [], JSON.parse(response.body)
  end

  private

  def access_events_path(uuid)
    "/api/v1/registrant/domains/#{uuid}/access_events"
  end

  def get_events(uuid)
    get access_events_path(uuid), as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }
    assert_response :ok
    JSON.parse(response.body)
  end

  def accessed_ats(body)
    body.map { |e| e['accessed_at'] }
  end

  def iso(parseable)
    Time.zone.parse(parseable).iso8601
  end

  def iso_time(time)
    time.iso8601
  end

  def with_setting(code, value)
    entry = SettingEntry.find_by(code: code)
    original = entry&.value
    if entry
      entry.update!(value: value)
    else
      SettingEntry.create!(code: code, value: value, format: 'integer', group: 'rdap')
    end
    yield
  ensure
    current = SettingEntry.find_by(code: code)
    if original
      current&.update!(value: original)
    else
      current&.destroy
    end
  end

  # Capture technical-log / error lines the endpoint emits at the application's own log level
  # (info+; SQL debug lines are not part of the endpoint's emitted output). The assertion is that
  # the endpoint's own logging carries no PII — our controller/query object make no log calls.
  def capture_rails_log
    io = StringIO.new
    logger = ActiveSupport::Logger.new(io)
    logger.level = Logger::INFO
    original = Rails.logger
    Rails.logger = logger
    yield
    io.string
  ensure
    Rails.logger = original
  end

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
